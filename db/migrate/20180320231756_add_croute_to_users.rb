class AddCrouteToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :c_route, :boolean
  end
end
