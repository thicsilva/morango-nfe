class Product < ApplicationRecord
  has_many :items
  belongs_to :cfop, optional: true

  validates :name, uniqueness: true
  validates :name, :unidade_comercial,
  presence: true


end
