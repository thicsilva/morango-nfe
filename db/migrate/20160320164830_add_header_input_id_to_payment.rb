class AddHeaderInputIdToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :header_input_id, :integer
  end
end
