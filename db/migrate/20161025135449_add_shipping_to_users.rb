class AddShippingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :shipping, :boolean
  end
end
