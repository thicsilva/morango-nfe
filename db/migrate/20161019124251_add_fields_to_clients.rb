class AddFieldsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :codigo_pais, :string
    add_column :clients, :pais, :string
  end
end
