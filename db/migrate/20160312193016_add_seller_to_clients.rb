class AddSellerToClients < ActiveRecord::Migration
  def change
    add_reference :clients, :seller, index: true, foreign_key: true
  end
end
