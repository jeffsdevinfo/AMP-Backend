class CreateUserContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_contacts do |t|
      t.string :street_address
      t.string :apartment
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.string :email
      t.references :user, null: false, foreign_key: true
      t.string :address_type

      t.timestamps
    end
  end
end
