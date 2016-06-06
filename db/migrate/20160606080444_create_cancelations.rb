class CreateCancelations < ActiveRecord::Migration
  def change
    create_table :cancelations do |t|
      t.belongs_to :reservation, null: false, index: true
      t.belongs_to :user,        null: true,  index: true
      t.timestamps
    end
  end
end
