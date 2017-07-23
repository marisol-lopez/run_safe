class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :contact_name
      t.string :contact_phone_number

      t.timestamps
    end
  end
end
