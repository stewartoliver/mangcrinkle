class CreateContactResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_responses do |t|
      t.references :contact_message, null: false, foreign_key: true
      t.string :admin_user
      t.text :response
      t.datetime :sent_at

      t.timestamps
    end
  end
end
