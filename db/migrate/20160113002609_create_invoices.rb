class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :type_invoice
      t.references :client, index: true, foreign_key: true
      t.string :status_invoice
      t.timestamps null: false
    end
  end
end
