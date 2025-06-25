class CreateProductSelections < ActiveRecord::Migration[7.1]
  def change
    create_table :product_selections do |t|
      t.references :cart_item, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end 