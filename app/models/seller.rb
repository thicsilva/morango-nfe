class Seller < ApplicationRecord
  belongs_to :estado, optional: true
  belongs_to :cidade, optional: true
  has_many :clients

  validates :name, uniqueness: true
  validates :name,
  presence: true

end
