class AddDataPrevendaToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :data_prevenda, :date
  end
end
