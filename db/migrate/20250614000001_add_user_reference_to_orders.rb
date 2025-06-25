class AddUserReferenceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :user, null: true, foreign_key: true
    
    # Make existing customer fields optional since they'll be stored in users table
    change_column_null :orders, :customer_name, true
    change_column_null :orders, :email, true
    change_column_null :orders, :phone, true
    change_column_null :orders, :address, true
  end
end 