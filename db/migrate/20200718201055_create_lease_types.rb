class CreateLeaseTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :lease_types do |t|
      t.string :lease_type

      t.timestamps
    end
  end
end
