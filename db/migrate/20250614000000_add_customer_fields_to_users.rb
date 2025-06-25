class AddCustomerFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :user_type, :string, default: 'customer'
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :address, :text
    add_column :users, :newsletter_subscribed, :boolean, default: false
    
    add_index :users, :user_type
    add_index :users, :newsletter_subscribed
  end
end 