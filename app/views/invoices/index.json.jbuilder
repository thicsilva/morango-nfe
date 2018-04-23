json.array!(@invoices) do |invoice|
  json.extract! invoice, :id, :type_invoice, :client_id
  json.url invoice_url(invoice, format: :json)
end
