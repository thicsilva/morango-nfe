class RemoveTotalsalevalueToItemInputs < ActiveRecord::Migration
  def change
    remove_column :item_inputs, :total_value_sale
  end
end
