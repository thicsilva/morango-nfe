class Supplier < ApplicationRecord
  belongs_to :cidade, optional: true
  belongs_to :estado, optional: true
  belongs_to :payment, optional: true
  belongs_to :header_input, optional: true

  validates :name, uniqueness: true
  validates :name, :address, :neighborhood, :zipcode, :phone, :cpf_cnpj, :email, :city, :state,
  presence: true
end
