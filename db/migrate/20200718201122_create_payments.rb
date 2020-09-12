class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.references :lease, null: false, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end
