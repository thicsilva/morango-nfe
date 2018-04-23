class AddPositionToClients < ActiveRecord::Migration[5.0]
  def change
    add_column :clients, :position, :integer
  end
end
