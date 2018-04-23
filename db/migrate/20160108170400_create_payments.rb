class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :doc_number
      t.string :description
      t.date :due_date
      t.date :payment_date
      t.integer :installments
      t.decimal :value_doc
      t.references :supplier, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
