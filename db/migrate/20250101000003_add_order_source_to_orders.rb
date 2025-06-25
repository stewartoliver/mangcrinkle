class AddOrderSourceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :order_source, :string, default: 'website'
    add_index :orders, :order_source
  end
end 