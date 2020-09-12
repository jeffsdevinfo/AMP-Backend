class AddDetailsToLease < ActiveRecord::Migration[6.0]
  def change
    add_column :leases, :start_date, :datetime
    add_column :leases, :end_date, :datetime
    add_column :leases, :first_month_rent, :decimal
    add_column :leases, :last_month_rent, :decimal
    add_column :leases, :security_deposit, :decimal
  end
end
