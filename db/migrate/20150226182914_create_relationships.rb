class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.belongs_to :user, null: false
      t.belongs_to :car,  null: false
      t.index      [:user_id, :car_id], unique: true
      t.string     :type, null: false
      t.index      :type
      t.timestamps
    end
  end
end
