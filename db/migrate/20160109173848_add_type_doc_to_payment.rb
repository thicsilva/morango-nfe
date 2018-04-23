class AddTypeDocToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :type_doc, :string
  end
end
