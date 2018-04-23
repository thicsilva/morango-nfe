json.array!(@clients) do |client|
  json.extract! client, :id, :name, :address, :neighborhood, :city, :state, :zipcode, :cnpj, :cellphone, :email
  json.url client_url(client, format: :json)
end
