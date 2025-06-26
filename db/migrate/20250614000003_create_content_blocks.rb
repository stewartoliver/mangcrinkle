class CreateContentBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :content_blocks do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.text :content
      t.text :description
      t.string :content_type, default: 'text'
      t.boolean :active, default: true
      t.json :metadata
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :content_blocks, :key, unique: true
    add_index :content_blocks, :active
    add_index :content_blocks, :content_type
    add_index :content_blocks, :sort_order
  end
end 