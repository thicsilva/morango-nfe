class AddNovosCamposToItemInputs < ActiveRecord::Migration[5.0]
  def change
    add_column :item_inputs, :cest, :integer
    add_column :item_inputs, :escala_relevante, :boolean
    add_column :item_inputs, :cnpj_fabricante, :string
    add_column :item_inputs, :codigo_beneficio_fiscal_uf, :string
  end
end
