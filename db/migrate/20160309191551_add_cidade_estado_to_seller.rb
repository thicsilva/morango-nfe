class AddCidadeEstadoToSeller < ActiveRecord::Migration
  def change
    add_reference :sellers, :cidade, index: true, foreign_key: true
    add_reference :sellers, :estado, index: true, foreign_key: true
  end
end
