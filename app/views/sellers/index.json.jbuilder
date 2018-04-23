json.array!(@sellers) do |seller|
  json.extract! seller, :id, :name, :address, :neighborhood, :city, :state, :zipcode, :phone, :celphone, :cpf, :email
  json.url seller_url(seller, format: :json)
end
