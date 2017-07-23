class AddUserToRun < ActiveRecord::Migration[5.0]
  def change
    add_reference :runs, :contact, foreign_key: true
    add_reference :runs, :user, foreign_key: true
  end
end
