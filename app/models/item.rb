class Item < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :product, optional: true
  has_many :routes, through: :invoice
  attr_accessor :id_do_item


    #quando usar um parametro que não existe no banco de dados, é preciso usar o atributo attr_accessor
  attr_accessor :apply_all

  validates :qnt, :sale_value, :total_value_sale, :product_id, presence: true

end
