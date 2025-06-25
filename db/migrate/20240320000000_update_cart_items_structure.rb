class UpdateCartItemsStructure < ActiveRecord::Migration[7.0]
  def change
    # Remove old columns
    remove_column :cart_items, :purchasable_type, :string
    remove_column :cart_items, :purchasable_id, :bigint
    remove_column :cart_items, :price, :decimal

    # Add new product_id column
    add_column :cart_items, :product_id, :bigint
    add_index :cart_items, :product_id

    # Add foreign key constraint
    add_foreign_key :cart_items, :products
  end
end 