class AddTcostAndTprofitToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :t_cost, :decimal
    add_column :receipts, :t_profit, :decimal
  end
end
