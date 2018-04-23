class AddConfigToExpireDates < ActiveRecord::Migration
  def change
    add_column :expire_dates, :razao, :string
    add_column :expire_dates, :nome_fantasia, :string
    add_column :expire_dates, :cnpj, :string
    add_column :expire_dates, :cep, :string
    add_column :expire_dates, :endereco, :string
    add_column :expire_dates, :numero, :integer
    add_column :expire_dates, :bairro, :string
    add_column :expire_dates, :cidade, :string
    add_column :expire_dates, :uf, :string
    add_column :expire_dates, :telefone, :string
    add_column :expire_dates, :inscricao, :string
    add_column :expire_dates, :check_date, :boolean
    add_column :expire_dates, :expiration_date, :date
    add_column :expire_dates, :check_env, :string
  end
end
