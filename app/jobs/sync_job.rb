require "csv"

class SyncJob < ActiveJob::Base
  queue_as :default

  def perform(store)
    branch_name = store.store_branch_name

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

    # merge master into branch
    result = clone_base.merge("master")

    #
    # get remote data
    #
    clone_base.tag(Time.now.strftime("sync-start--%Y-%m-%d--%H-%M-%S"));
    store.write_to_git
    clone_base.history

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
    store.process_changes(changes.first)
  end
end
