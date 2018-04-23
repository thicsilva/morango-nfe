class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :address
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :phone
      t.string :cnpj
      t.string :cellphone
      t.string :email

      t.timestamps null: false
    end
  end
end
