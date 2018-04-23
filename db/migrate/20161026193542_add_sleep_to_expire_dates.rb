class AddSleepToExpireDates < ActiveRecord::Migration
  def change
    add_column :expire_dates, :sleep, :integer
  end
end
