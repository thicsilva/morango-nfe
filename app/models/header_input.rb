class HeaderInput < ApplicationRecord
  belongs_to :supplier, optional: true

  # para poder permitir a exclusão da invoice mesmo tendo itens ou não
  has_many :item_inputs, dependent: :destroy

  validates :supplier_id, presence: true
end
