class CreateCancelations < ActiveRecord::Migration
  def change
    create_table :cancelations do |t|
      t.belongs_to :reservation, null: false
      t.belongs_to :user,        null: true
      t.timestamps
    end
  end
end
