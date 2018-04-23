class AddMinputToUser < ActiveRecord::Migration
  def change
    add_column :users, :minput, :boolean
  end
end
