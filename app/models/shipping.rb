class Shipping < ApplicationRecord
  belongs_to :invoice, optional: true
  validates :name, presence: true
end
