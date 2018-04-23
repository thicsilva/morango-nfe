class CreateCfops < ActiveRecord::Migration
  def change
    create_table :cfops do |t|
      t.integer :codigo
      t.string :descricao

      t.timestamps null: false
    end
  end
end
