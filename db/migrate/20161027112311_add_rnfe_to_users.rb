class AddRnfeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rnfe, :boolean
  end
end
