class AddMunicipioAndUfToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :municipio, :string
    add_column :sellers, :uf, :string
  end
end
