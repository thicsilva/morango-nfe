json.array!(@suppliers) do |supplier|
  json.extract! supplier, :id, :name, :address, :neighborhood, :zipcode, :phone, :cellphone, :cpf_cnpj, :email, :cidade_id, :estado_id
  json.url supplier_url(supplier, format: :json)
end
