class AddNovosCamposToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :cest, :integer
    add_column :items, :escala_relevante, :boolean
    add_column :items, :cnpj_fabricante, :string
    add_column :items, :codigo_beneficio_fiscal_uf, :string
  end
end
