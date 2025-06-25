class CreateCrinklePackages < ActiveRecord::Migration[7.1]
  def change
    create_table :crinkle_packages do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :quantity
      t.boolean :active

      t.timestamps
    end
  end
end
