class CreateRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :runs do |t|
      t.string :location
      t.string :end_time
      t.string :status

      t.timestamps
    end
  end
end
