class AddCodigoNcmToItems < ActiveRecord::Migration
  def change
    add_column :items, :codigo_ncm, :string
  end
end
