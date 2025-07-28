class App < ApplicationRecord
  has_many :availabilities
  has_many :contents, through: :availabilities

  validates :name, presence: true
end
