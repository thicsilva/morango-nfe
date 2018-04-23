class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.string :name
      t.string :address
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :phone
      t.string :celphone
      t.string :cpf
      t.string :email

      t.timestamps null: false
    end
  end
end
