class AddLegalFieldsToContentBlocks < ActiveRecord::Migration[7.1]
  def change
    add_column :content_blocks, :effective_date, :date
    add_column :content_blocks, :is_active, :boolean, default: true
    add_index :content_blocks, [:key, :is_active]
  end
end
