class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.belongs_to :user,       null: false, index: true
      t.belongs_to :car,        null: false, index: true
      t.datetime   :starts_at,  null: false
      t.index      :starts_at
      t.datetime   :ends_at,    null: false
      t.index      :ends_at
      t.timestamps
    end
  end
end
