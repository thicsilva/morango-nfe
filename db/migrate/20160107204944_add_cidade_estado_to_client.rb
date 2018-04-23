class AddCidadeEstadoToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :cidade, index: true, foreign_key: true
    add_reference :clients, :estado, index: true, foreign_key: true
  end
end
