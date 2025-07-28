class Availability < ApplicationRecord
  belongs_to :app
  belongs_to :content

  validates :market, presence: true

  after_commit :expire_caches

  private

  def expire_caches
    ExpireCachesJob.perform_later(market, content.type.underscore)
  end
end
