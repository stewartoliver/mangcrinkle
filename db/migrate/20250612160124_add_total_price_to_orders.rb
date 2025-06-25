class AddTotalPriceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :total_price, :decimal
  end
end
