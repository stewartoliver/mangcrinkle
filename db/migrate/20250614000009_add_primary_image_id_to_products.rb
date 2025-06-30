class AddPrimaryImageIdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :primary_image_id, :string
    add_index :products, :primary_image_id
  end
end 