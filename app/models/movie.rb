class Movie < Content
  validates :year, presence: true
  validates :duration_in_seconds, presence: true
end
