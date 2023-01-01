class AddCsvTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :csv_todos, id: :uuid do |t|
      t.integer :store_id
      t.string  :title
      t.integer :order
      t.boolean :done
      t.text :__git_options
    end
  end
end
