class CreateItemInputs < ActiveRecord::Migration
  def change
    create_table :item_inputs do |t|
      t.references :product, index: true, foreign_key: true
      t.decimal :cost_value
      t.decimal :sale_value
      t.integer :qnt
      t.decimal :total_value_cost
      t.decimal :total_value_sale
      t.references :header_input, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
