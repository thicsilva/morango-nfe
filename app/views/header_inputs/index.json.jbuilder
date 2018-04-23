json.array!(@header_inputs) do |header_input|
  json.extract! header_input, :id, :client_id
  json.url header_input_url(header_input, format: :json)
end
