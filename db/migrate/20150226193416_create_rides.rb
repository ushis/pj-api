class CreateRides < ActiveRecord::Migration
  def change
    create_table :rides do |t|
      t.belongs_to :user,           null: true,   index: true
      t.belongs_to :car,            null: false,  index: true
      t.integer    :distance,       null: false
      t.index      :distance
      t.datetime   :started_at,     null: false
      t.index      :started_at
      t.datetime   :ended_at,       null: false
      t.index      :ended_at
      t.integer    :comments_count, null: false, default: 0
      t.timestamps
    end
  end
end
