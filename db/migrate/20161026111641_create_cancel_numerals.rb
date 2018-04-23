class CreateCancelNumerals < ActiveRecord::Migration
  def change
    create_table :cancel_numerals do |t|
      t.string :cnpj
      t.string :user
      t.integer :serie
      t.integer :inicial_number
      t.integer :final_number
      t.string :justificativa
      t.string :url_xml

      t.timestamps null: false
    end
  end
end
