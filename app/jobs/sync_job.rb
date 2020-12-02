require "csv"

class SyncJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"

    branch_name = "csv"

    git_base = GitBaseRails.git_base(branch_name: branch_name)

    # clone the repo
    if git_base.exists?
      clone_base = git_base
    else
      clone_base = git_base.clone(GitBaseRails.git_db_directory(branch_name: branch_name), "bin")

      # checkout branch
      clone_base.switch_to_branch(branch_name)
    end

    #
    # get remote data
    #
    clone_base.tag(Time.now.strftime("sync-%Y-%m-%d--%H-%M-%S"));
    CSV.open("todo.csv") do |csv|
      todo = Csv::Todo.find_by_store_id(csv[0])
      if todo
        todo.update(title: csv[1], order: csv[2], done: csv[3].present?)
      else
        Csv::Todo.create(store_id: csv[0], title: csv[1], order: csv[2], done: csv[3].present?)
      end
    end
    clone_base.history

    # merge master into branch
    conflicts = clone_base.merge("master")

    if conflicts.present?
      # fix conflicts
    end

    # checkout master
    clone_base.switch_to_branch("master")

    # merge branch
    clone_base..merge(branch_name)

    # pull from origin
    clone_base.fetch("origin")

    # push to origin
    clone_base.push("origin")
  end
end
