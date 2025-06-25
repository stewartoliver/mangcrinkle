class CreateOrderNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :order_notes do |t|
      t.references :order, null: false, foreign_key: true
      t.text :content, null: false
      t.string :admin_user, null: false

      t.timestamps
    end
    
    add_index :order_notes, :created_at
  end
end 