class AddConsultanfeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mconsul_nfe, :boolean
  end
end
