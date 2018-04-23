class ItemInput < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :header_input, optional: true
  after_create :atualiza_custo

  def atualiza_custo

    itens = ItemInput.where('created_at::Date = ?', Date.today).where(product_id: product_id)
    itens.each do |item|
      puts item.product_id.to_s + ' quantidade ' + item.qnt.to_s + ' total pago ' + item.total_value_cost.to_s
    end
  end

  validates :qnt, :cost_value, :total_value_cost, :product_id, presence: true
end
