class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :doc_number
      t.string :type_doc
      t.string :discription
      t.date :due_date
      t.date :receipt_date
      t.integer :installments
      t.decimal :value_doc
      t.references :client, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
