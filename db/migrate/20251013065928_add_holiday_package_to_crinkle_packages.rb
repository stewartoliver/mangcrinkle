class AddHolidayPackageToCrinklePackages < ActiveRecord::Migration[7.1]
  def change
    add_column :crinkle_packages, :holiday_package, :boolean, default: false, comment: "Whether this is a holiday-specific package"
    add_index :crinkle_packages, :holiday_package
  end
end
