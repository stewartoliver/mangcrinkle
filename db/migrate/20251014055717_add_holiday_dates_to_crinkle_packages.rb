class AddHolidayDatesToCrinklePackages < ActiveRecord::Migration[7.1]
  def change
    add_column :crinkle_packages, :holiday_start_date, :date
    add_column :crinkle_packages, :holiday_end_date, :date
  end
end
