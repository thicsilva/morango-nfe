class AddUploadToUser < ActiveRecord::Migration
  def change
    add_column :users, :mupload, :boolean
  end
end
