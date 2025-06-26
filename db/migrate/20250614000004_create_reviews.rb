class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.string :customer_name, null: false
      t.string :email, null: false
      t.integer :rating, null: false
      t.text :content, null: false
      t.boolean :approved, default: false
      t.boolean :featured, default: false
      t.text :admin_notes
      t.datetime :approved_at
      t.references :approved_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :reviews, :approved
    add_index :reviews, :featured
    add_index :reviews, :rating
    add_index :reviews, :email
    add_index :reviews, :created_at
  end
end 