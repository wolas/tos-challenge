class Availability < ApplicationRecord
  belongs_to :app
  belongs_to :content

  validates :market, presence: true
end
