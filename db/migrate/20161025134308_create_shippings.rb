class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
      t.string :name
      t.string :cep
      t.string :address
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :phone
      t.string :cnpj
      t.string :inscricao

      t.timestamps null: false
    end
  end
end
