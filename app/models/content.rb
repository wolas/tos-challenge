class Content < ApplicationRecord
  has_many :availabilities
  has_many :apps, through: :availabilities

  validates :original_title, presence: true
end
