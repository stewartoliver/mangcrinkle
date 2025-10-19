class CreatePackageProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :package_products do |t|
      t.bigint :package_id, null: false
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 0, comment: "Default quantity for this product in the package"
      t.boolean :required, default: false, comment: "Whether this product is required in the package"
      t.boolean :active, default: true, comment: "Whether this product is available for selection in this package"

      t.timestamps
    end
    
    add_foreign_key :package_products, :crinkle_packages, column: :package_id
    add_index :package_products, [:package_id, :product_id], unique: true
    add_index :package_products, :active
  end
end
