class CreateContactMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subject
      t.text :message
      t.string :status
      t.string :priority
      t.datetime :responded_at
      t.string :admin_user

      t.timestamps
    end
  end
end
