class Invoice < ApplicationRecord
  belongs_to :client, optional: true
  has_many :routes, through: :client
  belongs_to :cidade, optional: true
  belongs_to :estado, optional: true
  belongs_to :shipping, optional: true
  belongs_to :route, optional: true
  has_many :items
  # para poder permitir a exclusão da invoice mesmo tendo itens ou não
  has_many :items, dependent: :destroy

  validates :type_invoice, :client_id, :data_prevenda, presence: true


end
