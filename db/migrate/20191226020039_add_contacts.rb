class AddContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :name
      t.string :phone
      t.string :email
    end
  end
end
