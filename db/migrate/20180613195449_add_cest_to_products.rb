class AddCestToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :cest, :string
  end
end
