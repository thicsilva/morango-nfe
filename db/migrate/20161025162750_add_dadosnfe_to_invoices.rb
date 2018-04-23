class AddDadosnfeToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :natureza_operacao, :string
    add_column :invoices, :forma_pagamento_nf, :integer
    add_column :invoices, :data_emissao, :date
    add_column :invoices, :data_entrada_saida, :date
    add_column :invoices, :tipo_documento, :integer
    add_column :invoices, :finalidade_emissao, :integer
    add_column :invoices, :icms_base_calculo, :decimal
    add_column :invoices, :icms_valor_total, :decimal
    add_column :invoices, :icms_base_calculo_st, :decimal
    add_column :invoices, :icms_valor_total_st, :decimal
    add_column :invoices, :valor_frete, :decimal
    add_column :invoices, :valor_seguro, :decimal
    add_column :invoices, :valor_total, :decimal
    add_column :invoices, :valor_produtos, :decimal
    add_column :invoices, :valor_ipi, :decimal
    add_column :invoices, :modalidade_frete, :integer
    add_column :invoices, :informacoes_adicionais_contribuinte, :text
    add_reference :invoices, :shipping, index: true, foreign_key: true
    add_column :invoices, :veiculo_placa, :string
    add_column :invoices, :veiculo_uf, :string
    add_column :invoices, :veiculo_rntc, :string
    add_column :invoices, :quantidade_volume, :integer
    add_column :invoices, :especie, :string
    add_column :invoices, :marca, :string
    add_column :invoices, :numero, :string
    add_column :invoices, :peso_bruto, :decimal
    add_column :invoices, :peso_liquido, :decimal
    add_column :invoices, :url_danfe, :string
    add_column :invoices, :url_xml, :string
    add_column :invoices, :justificativa_cancelamento, :string
    add_column :invoices, :just_correcao, :string
    add_column :invoices, :caminho_xml_correcao, :string
    add_column :invoices, :caminho_pdf_correcao, :string
    add_column :invoices, :caminho_xml_cancelamento, :string
  end
end
