class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.belongs_to :car,    null: false, index: true
      t.string     :type,   null: false
      t.index      :type
      t.string     :email,  null: false
      t.index      [:car_id, :email], unique: true
      t.timestamps
    end
  end
end
