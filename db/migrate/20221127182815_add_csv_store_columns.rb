class AddCsvStoreColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :stores, :type, :string
    add_column :stores, :filename, :string
  end
end
