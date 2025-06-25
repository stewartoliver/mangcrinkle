class AddPolymorphicToLineItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :line_items, :purchasable, polymorphic: true, null: false
  end
end
