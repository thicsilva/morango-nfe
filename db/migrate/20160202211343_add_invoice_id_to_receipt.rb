class AddInvoiceIdToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :invoice_id, :integer
  end
end
