class RenameCsvTable < ActiveRecord::Migration[6.0]
  def change
    rename_table :csv_todos, :csv_store_todos
  end
end
