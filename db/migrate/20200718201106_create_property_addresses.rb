class CreatePropertyAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :property_addresses do |t|
      t.string :street_address
      t.string :apartment
      t.string :zip
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
