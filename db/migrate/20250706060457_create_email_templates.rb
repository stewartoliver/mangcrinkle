class CreateEmailTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :subject
      t.text :body
      t.string :template_type
      t.boolean :active
      t.text :variables

      t.timestamps
    end
  end
end
