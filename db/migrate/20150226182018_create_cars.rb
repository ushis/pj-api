class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.string  :name,   null: false
      t.index   :name
      t.timestamps
    end
  end
end
