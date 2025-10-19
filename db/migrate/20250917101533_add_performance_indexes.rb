class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :orders, :phone unless index_exists?(:orders, :phone)
    add_index :orders, :created_at unless index_exists?(:orders, :created_at)
    add_index :line_items, [:purchasable_id, :purchasable_type] unless index_exists?(:line_items, [:purchasable_id, :purchasable_type])
    add_index :reviews, :approved unless index_exists?(:reviews, :approved)
  end
end
