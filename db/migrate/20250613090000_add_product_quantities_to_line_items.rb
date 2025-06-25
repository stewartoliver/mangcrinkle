class AddProductQuantitiesToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_column :line_items, :product_quantities, :text
  end
end 