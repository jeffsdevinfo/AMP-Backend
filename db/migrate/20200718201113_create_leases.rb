class CreateLeases < ActiveRecord::Migration[6.0]
  def change
    create_table :leases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lease_type, null: false, foreign_key: true
      t.boolean :status
      t.decimal :monthly_rent_price
      t.decimal :balance
      t.references :property_address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
