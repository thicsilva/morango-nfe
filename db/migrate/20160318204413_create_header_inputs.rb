class CreateHeaderInputs < ActiveRecord::Migration
  def change
    create_table :header_inputs do |t|
      t.references :supplier, index: true, foreign_key: true
      t.string :form_payment
      t.string :status

      t.timestamps null: false
    end
  end
end
