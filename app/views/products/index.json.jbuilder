json.array!(@products) do |product|
  json.extract! product, :id, :name, :qnt, :cost_value, :cost_sale, :supplier_id
  json.url product_url(product, format: :json)
end
