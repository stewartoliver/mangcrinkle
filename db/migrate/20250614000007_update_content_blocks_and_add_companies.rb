class UpdateContentBlocksAndAddCompanies < ActiveRecord::Migration[7.1]
  def change
    # Remove fields from content_blocks
    remove_column :content_blocks, :usage_context, :text
    remove_column :content_blocks, :sort_order, :integer
    remove_column :content_blocks, :description, :text
    
    # Create companies table
    create_table :companies do |t|
      t.string :name, null: false
      t.string :website
      t.text :address
      t.string :phone
      t.string :email
      t.json :business_hours
      t.text :description
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    # Add indexes for companies
    add_index :companies, :name
    add_index :companies, :active
    add_index :companies, :email
  end
end 