class Lease < ApplicationRecord
  belongs_to :user
  belongs_to :lease_type
  belongs_to :property_address
  has_many :payments
end
