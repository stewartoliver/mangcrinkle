class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.string :email
      t.string :phone
      t.text :address
      t.string :status
      t.decimal :total

      t.timestamps
    end
  end
end
