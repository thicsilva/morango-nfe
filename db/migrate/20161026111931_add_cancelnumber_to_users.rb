class AddCancelnumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mcancel_number, :boolean
  end
end
