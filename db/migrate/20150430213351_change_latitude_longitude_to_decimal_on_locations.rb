class ChangeLatitudeLongitudeToDecimalOnLocations < ActiveRecord::Migration
  def change
    change_table :locations do |t|
      t.change :latitude,  :decimal
      t.change :longitude, :decimal
    end
  end
end
