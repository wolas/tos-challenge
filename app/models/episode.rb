class Episode < Content
  belongs_to :season

  validates :year, presence: true
  validates :episode_number, presence: true
  validates :duration_in_seconds, presence: true
end
