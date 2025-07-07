class AddActivationStatusToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :activated_at, :datetime
    add_column :users, :activation_token, :string
  end
end
