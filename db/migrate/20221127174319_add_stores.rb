class AddStores < ActiveRecord::Migration[6.0]
  def change
    create_table :stores, id: :uuid do |t|
      t.string :name
      t.datetime :last_synced_at
      t.timestamps
    end
  end
end
