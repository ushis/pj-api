class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :user,        index: true
      t.belongs_to :commentable, index: true, null: false
      t.string     :type,        null: false
      t.index      :type
      t.text       :comment
      t.timestamps
    end
  end
end
