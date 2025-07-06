class CreateReviewSpamTrackers < ActiveRecord::Migration[7.1]
  def change
    create_table :review_spam_trackers do |t|
      t.string :ip_address, null: false
      t.string :email, null: false
      t.text :user_agent
      t.integer :attempt_count, default: 1
      
      t.timestamps
    end
    
    add_index :review_spam_trackers, :ip_address
    add_index :review_spam_trackers, :email
    add_index :review_spam_trackers, :created_at
  end
end 