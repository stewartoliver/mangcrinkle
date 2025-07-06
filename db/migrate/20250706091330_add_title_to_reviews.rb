class AddTitleToReviews < ActiveRecord::Migration[7.1]
  def change
    add_column :reviews, :title, :string, limit: 100
    add_index :reviews, :title
  end
end 