class AddFcpToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :fcp_percentual_uf_destino, :decimal
    add_column :items, :fcp_valor_uf_destino, :decimal
    add_column :items, :fcp_base_calculo_uf_destino, :decimal
  end
end
