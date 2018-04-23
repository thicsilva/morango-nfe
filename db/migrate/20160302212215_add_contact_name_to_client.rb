class AddContactNameToClient < ActiveRecord::Migration
  def change
    add_column :clients, :contact_name, :string
  end
end
