require "csv"

class SyncJob < ActiveJob::Base
  queue_as :default

  def perform(store_id)
    store = Store.find(store_id)
    branch_name = store.store_branch_name

    git_base = GitBaseRails.git_base(branch_name: branch_name, set_class_var: false, initialize_if_doesnt_exist: false)

    master_base = GitBaseRails.git_base(branch_name: 'master', set_class_var: false)
    bare_base = GitBaseRails.git_base(branch_name: 'bare', set_class_var: false)

    store_base = find_or_create_store_repo(bare_base, git_base, branch_name)

    # commit remote data into store branch
    store_base.tag(Time.now.strftime("sync-start--%Y-%m-%d--%H-%M-%S"));
    store.update_git_from_remote
    store_base.history

    # merge master into store branch
    result = store_base.merge("master")

    if result.conflicts?
      # fix conflicts
    end

    # switch store repo to master branch
    store_base.switch_to_branch("master")

    # merge store branch into master branch
    store_base.merge(branch_name)

    # pull and push to/from origin
    store_base.fetch("origin")
    store_base.push("origin", "master")

    # Get ready to detect changes in master repo on the master branch
    changes = []
    listener = Listen.to(GitBaseRails.git_db_directory(branch_name: 'master')) do |mod, add, rem|
      changes.push({mod: mod, add: add, rem: rem})
    end
    listener.start

    # pull master from origin
    master_base.pull("origin", "master")
    sleep 0.3
    listener.stop

    puts changes

    # detect changes in master directory and update database
    store.process_changes(changes.first)
  end

  def find_or_create_store_repo(bare_base, git_base, branch_name)
    if git_base.exists?
      # update store repo
      store_base = git_base

      # checkout branch
      store_base.switch_to_branch(branch_name, create: false)
    else
      # clone the repo
      store_base = bare_base.clone(GitBaseRails.git_db_directory(branch_name: branch_name), "bin")

      # checkout branch
      store_base.switch_to_branch(branch_name, create: true)
    end

    store_base
  end
end


