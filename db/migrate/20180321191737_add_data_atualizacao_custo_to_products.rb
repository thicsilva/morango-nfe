class AddDataAtualizacaoCustoToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :data_atualizacao_custo, :date
  end
end
