class EnhanceProductsWithShortDescriptionAndMultipleImages < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :short_description, :text
    # Note: Keeping the existing image string column for now
    # Will be removed in a future migration after data migration
  end
end 