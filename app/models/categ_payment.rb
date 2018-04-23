class CategPayment < ApplicationRecord
  has_many :payments

  validates :name, uniqueness: true
  validates :name,
  presence: true

end
