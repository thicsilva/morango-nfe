class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :address
      t.string :neighborhood
      t.string :zipcode
      t.string :phone
      t.string :cellphone
      t.string :cpf_cnpj
      t.string :email
      t.references :cidade, index: true, foreign_key: true
      t.references :estado, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
