class RemoveSalevalueAndTotalsalevalueToItemInputs < ActiveRecord::Migration
  def change
    remove_column :item_inputs, :sale_value, :total_value_sale
  end
end
