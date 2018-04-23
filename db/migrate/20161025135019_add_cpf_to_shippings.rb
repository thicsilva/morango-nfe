class AddCpfToShippings < ActiveRecord::Migration
  def change
    add_column :shippings, :cpf, :string
  end
end
