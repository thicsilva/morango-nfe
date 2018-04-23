class AddCategPaymentToPayments < ActiveRecord::Migration
  def change
    add_reference :payments, :categ_payment, index: true, foreign_key: true
  end
end
