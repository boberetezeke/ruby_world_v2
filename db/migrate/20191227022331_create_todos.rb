class CreateTodos < ActiveRecord::Migration[6.0]
  def change
    create_table :todos, id: :uuid do |t|
      t.string :short_description
      t.integer :order
      t.string :state

      t.timestamps
    end
  end
end
