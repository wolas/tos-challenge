class TvShow < Content
  has_many :seasons

  validates :year, presence: true
end
