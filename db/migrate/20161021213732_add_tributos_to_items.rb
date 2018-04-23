class AddTributosToItems < ActiveRecord::Migration
  def change
    add_column :items, :cfop, :integer
    add_column :items, :ipi_situacao_tributaria, :string
    add_column :items, :icms_situacao_tributaria, :string
    add_column :items, :pis_situacao_tributaria, :string
    add_column :items, :cofins_situacao_tributaria, :string
  end
end
