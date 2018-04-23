class AddTokenToExpireDates < ActiveRecord::Migration
  def change
    add_column :expire_dates, :url_server_test, :string
    add_column :expire_dates, :token_test, :string
    add_column :expire_dates, :url_server_production, :string
    add_column :expire_dates, :token_production, :string
    add_column :expire_dates, :port, :integer
  end
end
