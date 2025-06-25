class AddProductCategories < ActiveRecord::Migration[7.1]
  def up
    # Add index to category field for better performance
    add_index :products, :category
    
    # Add some default categories to existing products if they don't have one
    execute <<-SQL
      UPDATE products 
      SET category = 'Crinkles' 
      WHERE category IS NULL OR category = ''
    SQL
  end

  def down
    remove_index :products, :category
  end
end 