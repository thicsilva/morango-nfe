class CreateExpireDates < ActiveRecord::Migration
  def change
    create_table :expire_dates do |t|
      t.date :date_expire
      t.boolean :active

      t.timestamps null: false
    end
  end
end
