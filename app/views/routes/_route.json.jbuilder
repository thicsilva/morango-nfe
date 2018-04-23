json.extract! route, :id, :name, :created_at, :updated_at
json.url route_url(route, format: :json)
