json.array!(@expire_dates) do |expire_date|
  json.extract! expire_date, :id, :date_expire, :active
  json.url expire_date_url(expire_date, format: :json)
end
