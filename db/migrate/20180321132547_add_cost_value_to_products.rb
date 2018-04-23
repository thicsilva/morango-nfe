class AddCostValueToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :cost_value, :decimal
  end
end
