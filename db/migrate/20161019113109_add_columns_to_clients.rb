class AddColumnsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :cpf, :string
    add_column :clients, :numero, :string
    add_column :clients, :complemento, :string
    add_column :clients, :cod_municipio, :string
    add_column :clients, :indicador_inscr, :string
    add_column :clients, :inscr_est, :string
    add_column :clients, :inscr_suframa, :string
    add_column :clients, :inscr_municipal, :string
  end
end
