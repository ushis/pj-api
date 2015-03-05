class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string  :name,            null: false
      t.index   :name
      t.integer :mileage,         null: false, default: 0
      t.integer :rides_count,     null: false, default: 0
      t.integer :owners_count,    null: false, default: 0
      t.integer :borrowers_count, null: false, default: 0
      t.timestamps
    end
  end
end
