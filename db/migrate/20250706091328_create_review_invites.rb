class CreateReviewInvites < ActiveRecord::Migration[7.1]
  def change
    create_table :review_invites do |t|
      t.references :order, null: true, foreign_key: true
      t.string :email, null: false
      t.string :name, null: false
      t.string :token, null: false
      t.datetime :expires_at
      t.datetime :used_at
      t.datetime :sent_at
      t.text :admin_notes
      t.string :invite_type, default: 'order', null: false # 'order' or 'manual'
      
      t.timestamps
    end
    
    add_index :review_invites, :token, unique: true
    add_index :review_invites, :email
    add_index :review_invites, :expires_at
    add_index :review_invites, :used_at
    add_index :review_invites, :invite_type
  end
end 