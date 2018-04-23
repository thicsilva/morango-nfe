class AddProfitSaleToItems < ActiveRecord::Migration
  def change
    add_column :items, :profit_sale, :decimal
  end
end
