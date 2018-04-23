class AddCityAndStateToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :city, :string
    add_column :suppliers, :state, :string
  end
end
