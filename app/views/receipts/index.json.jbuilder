json.array!(@receipts) do |receipt|
  json.extract! receipt, :id, :doc_number, :type_doc, :discription, :due_date, :receipt_date, :installments, :value_doc, :client_id
  json.url receipt_url(receipt, format: :json)
end
