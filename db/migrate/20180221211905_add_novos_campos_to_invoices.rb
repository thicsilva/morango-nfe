class AddNovosCamposToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :valor_troco, :decimal
  end
end
