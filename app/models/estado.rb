class Estado < ApplicationRecord
  has_many :cidades
  has_many :clients
  has_many :suppliers
  has_many :invoices
  has_many :transports

  belongs_to :capital, :class_name => 'Cidade'

  def estado_params
    params.require(:estado).permit(:nome, :sigla, :capital)
  end
end
