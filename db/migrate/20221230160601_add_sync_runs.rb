class AddSyncRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :sync_runs, id: :uuid do |t|
      t.string :status
      t.timestamps
    end

    create_table :sync_conflicts, id: :uuid do |t|
      t.string :object_id
      t.text :conflict_info
      t.references :sync_runs, index: true
    end

    create_table :store_sync_runs, id: :uuid do |t|
      t.references :sync_runs, index: true
      t.references :stores, index: true
    end
  end
end
