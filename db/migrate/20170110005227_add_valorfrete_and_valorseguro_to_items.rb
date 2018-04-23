class AddValorfreteAndValorseguroToItems < ActiveRecord::Migration
  def change
    add_column :items, :valor_frete, :decimal
    add_column :items, :valor_seguro, :decimal
  end
end
