class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :qnt
      t.decimal :cost_value
      t.decimal :sale_value
      t.decimal :total_value_cost
      t.decimal :total_value_sale
      t.references :product, index: true, foreign_key: true
      t.references :invoice, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
