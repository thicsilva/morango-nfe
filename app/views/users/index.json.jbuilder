json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :password_digest, :type_access
  json.url user_url(user, format: :json)
end
