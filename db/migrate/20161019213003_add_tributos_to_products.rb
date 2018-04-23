class AddTributosToProducts < ActiveRecord::Migration
  def change
    add_column :products, :unidade_comercial, :string
    add_column :products, :codigo_ncm, :string
  end
end
