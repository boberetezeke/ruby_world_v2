require "csv"

class SyncJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"

    branch_name = "csv"

    git_base = GitBaseRails.git_base(branch_name: branch_name, set_class_var: false, initialize_if_doesnt_exist: false)

    master_base = GitBaseRails.git_base(branch_name: 'master', set_class_var: false)
    bare_base = GitBaseRails.git_base(branch_name: 'bare', set_class_var: false)

    # clone the repo
    if git_base.exists?
      clone_base = git_base
    else
      clone_base = bare_base.clone(GitBaseRails.git_db_directory(branch_name: branch_name), "bin")

      # checkout branch
      clone_base.switch_to_branch(branch_name, create: true)
    end

    #
    # get remote data
    #
    clone_base.tag(Time.now.strftime("sync-%Y-%m-%d--%H-%M-%S"));
    CSV.foreach("todo.csv") do |row|
      todo = CsvStoreTodo.find_by_store_id(row[0])
      if todo
        todo.update(title: row[1], order: row[2], done: row[3].present?)
      else
        CsvStoreTodo.create(store_id: row[0], title: row[1], order: row[2], done: row[3].present?)
      end
    end
    clone_base.history

    # merge master into branch
    result = clone_base.merge("master")

    if result.conflicts?
      # fix conflicts
    end

    # checkout master
    clone_base.switch_to_branch("master")

    # merge branch
    clone_base.merge(branch_name)

    # pull from origin
    clone_base.fetch("origin")

    # push to origin
    clone_base.push("origin", "master")

    changes = []
    listener = Listen.to(GitBaseRails.git_db_directory(branch_name: 'master')) do |mod, add, rem|
      changes.push({mod: mod, add: add, rem: rem})
    end
    listener.start

    # pull from origin
    master_base.pull("origin", "master")
    sleep 0.3
    listener.stop

    puts changes

    # detect changes in master directory and update database
    process_changes(changes.first)
  end

  def process_changes(changes)
    process_mods(changes[:mod])
    process_adds(changes[:add])
    process_removals(changes[:rem])
  end

  def process_mods(mods)
    mods.each do |mod|
      attributes = YAML.load(File.open(mod))
      todo = Todo.find(attributes['id'])
      todo.update_attributes(attributes)
    end
  end

  def process_adds(adds)
    adds.each do |add|
      attributes = YAML.load(File.open(add))
      Todo.create(attributes)
    end
  end

  def process_removals(removals)
    removals.each do |removal|
      attributes = YAML.load(File.open(removal))
      Todo.destroy(attributes['id'])
    end
  end
end
