class AddUpdatedCostToExpireDates < ActiveRecord::Migration[5.0]
  def change
    add_column :expire_dates, :updated_cost, :date
  end
end
