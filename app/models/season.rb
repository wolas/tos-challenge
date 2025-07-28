class Season < Content
  belongs_to :tv_show

  has_many :episodes

  validates :year, presence: true
  validates :season_number, presence: true
end
