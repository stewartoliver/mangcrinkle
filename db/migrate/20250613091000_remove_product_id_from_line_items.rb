class RemoveProductIdFromLineItems < ActiveRecord::Migration[7.1]
  def change
    # Remove the foreign key constraint first
    remove_foreign_key :line_items, :products
    
    # Remove the product_id column
    remove_column :line_items, :product_id, :bigint
    
    # Remove the index on product_id
    remove_index :line_items, :product_id if index_exists?(:line_items, :product_id)
  end
end 