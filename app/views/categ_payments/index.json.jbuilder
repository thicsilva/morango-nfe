json.array!(@categ_payments) do |categ_payment|
  json.extract! categ_payment, :id, :name
  json.url categ_payment_url(categ_payment, format: :json)
end
