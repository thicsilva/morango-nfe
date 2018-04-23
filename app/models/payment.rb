class Payment < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :categ_payment, optional: true

  validates :description, :due_date, :installments, :value_doc, :supplier_id, :status,
  presence: true

end
