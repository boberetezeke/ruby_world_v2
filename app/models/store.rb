class Store < ApplicationRecord
  has_many :sync_store_runs
  has_many :sync_runs, through: :sync_store_runs

  def add
  end

  def sync
  end

  def accumulate_changes
    {
      remote_changes: accumulate_local_changes,
      local_changes:  accumulate_remote_changes
    }
  end

  def accumulate_local_changes
    CsvStoreTodo.history_since('before-accumulate').entries
    #   # update from main DB
    #   changes = main_db.history_since(store.last_sync_time_date)
    #   store.update_from_main_db_changes(changes)
  end

  def accumulate_remote_changes
    #   store.update_from_remote
  end

  def process_changes(changes)
    return if changes.nil?

    process_mods(changes[:mod])
    process_adds(changes[:add])
    process_removals(changes[:rem])
  end

  def store_class
    raise "store_class must be set by the sub-class"
  end

  def store_branch_name
    raise "store_branch_name must be set by the sub-class"
  end

  def process_mods(mods)
    mods.each do |mod|
      attributes = YAML.load(File.open(mod))
      todo = store_class.find(attributes['id'])
      todo.update_attributes(attributes)
    end
  end

  def process_adds(adds)
    adds.each do |add|
      attributes = YAML.load(File.open(add))
      store_class.create(attributes)
    end
  end

  def process_removals(removals)
    removals.each do |removal|
      attributes = YAML.load(File.open(removal))
      store_class.destroy(attributes['id'])
    end
  end
end