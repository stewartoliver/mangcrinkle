class AddIngredientsAndAllergenInfoToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :ingredients, :text
    add_column :products, :allergen_info, :text
    add_column :products, :storage_instructions, :text
  end
end 