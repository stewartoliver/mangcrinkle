class AddTrackingFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :tracking_number, :string
    add_column :orders, :shipping_carrier, :string
    add_column :orders, :estimated_delivery, :date
    add_column :orders, :shipped_at, :datetime
    add_column :orders, :delivered_at, :datetime
    
    add_index :orders, :tracking_number
    add_index :orders, :shipped_at
    add_index :orders, :delivered_at
  end
end 