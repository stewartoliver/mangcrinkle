class AddPackageToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :cart_items, :crinkle_package, null: true, foreign_key: true
    add_column :cart_items, :product_quantities, :text
  end
end
