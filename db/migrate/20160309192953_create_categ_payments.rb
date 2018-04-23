class CreateCategPayments < ActiveRecord::Migration
  def change
    create_table :categ_payments do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
