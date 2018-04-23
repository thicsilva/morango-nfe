class Cidade < ApplicationRecord
  belongs_to :estado, optional: true
  has_many :clients
  has_many :suppliers
  has_many :invoices

end
