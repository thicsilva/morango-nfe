class AddRcompraToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :r_compra, :boolean
  end
end
