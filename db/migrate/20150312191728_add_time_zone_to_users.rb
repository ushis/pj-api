class AddTimeZoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, null: true
  end
end
