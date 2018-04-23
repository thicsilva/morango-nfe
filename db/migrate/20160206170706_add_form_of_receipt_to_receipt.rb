class AddFormOfReceiptToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :form_receipt, :string
  end
end
