class SyncRun < ApplicationRecord
  has_many :stores
  has_many :sync_conflicts

  has_many :sync_store_runs
  has_many :stores, through: :sync_store_runs

  def accumulate_changes
    store_changes = {}
    stores.each do |store|
      store_changes[store.id] = store.accumulate_changes
    end
  end

  def has_conflicts?

  end

  def apply_changes

  end
end