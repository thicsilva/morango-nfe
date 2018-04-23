class Receipt < ApplicationRecord
  belongs_to :client, optional: true

  validates :type_doc, :discription, :due_date, :installments, :value_doc, :client_id, :status,
  presence: true

  #se for fazer a baixa e não informar a data de recebimento
  #validates :receipt_date, presence: true, on: :update
end
