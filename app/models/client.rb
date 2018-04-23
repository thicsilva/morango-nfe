class Client < ApplicationRecord
  belongs_to :cidade, optional: true
  belongs_to :estado, optional: true
  has_many :receipts
  belongs_to :seller, optional: true
  belongs_to :route, optional: true
  has_many :invoices


  validates :name, uniqueness: true
  validates :name, :address, :neighborhood, :email, :city, :state, :seller_id, :numero, :route_id, :position, presence: true
end
