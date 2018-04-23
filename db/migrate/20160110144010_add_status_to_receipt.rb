class AddStatusToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :status, :string
  end
end
