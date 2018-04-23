class AddFormPaymentToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :form_payment, :string
  end
end
