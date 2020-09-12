class Payment < ApplicationRecord
  belongs_to :lease

  validates :amount, numericality: true
end
