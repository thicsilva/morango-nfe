json.array!(@shippings) do |shipping|
  json.extract! shipping, :id, :name, :cep, :address, :neighborhood, :city, :state, :phone, :cnpj, :inscricao
  json.url shipping_url(shipping, format: :json)
end
