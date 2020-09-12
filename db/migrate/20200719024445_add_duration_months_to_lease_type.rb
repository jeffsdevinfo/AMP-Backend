class AddDurationMonthsToLeaseType < ActiveRecord::Migration[6.0]
  def change
    add_column :lease_types, :duration_months, :integer
  end
end
