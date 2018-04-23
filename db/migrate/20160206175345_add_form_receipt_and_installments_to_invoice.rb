class AddFormReceiptAndInstallmentsToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :form_receipt, :string
    add_column :invoices, :installments, :integer
  end
end
