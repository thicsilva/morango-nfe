class Route < ApplicationRecord
  belongs_to :invoice
  belongs_to :client, optional: true
  validates :name, presence: true
  validates :name, uniqueness: true
end
