class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.belongs_to  :user,      null: true,  index: true
      t.belongs_to  :car,       null: false, index: true
      t.float       :latitude,  null: false
      t.float       :longitude, null: false
      t.timestamps
    end
  end
end
