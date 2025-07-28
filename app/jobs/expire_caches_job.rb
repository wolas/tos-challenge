class ExpireCachesJob < ApplicationJob
  queue_as :default

  def perform(market, content_type)
    redis = Rails.cache.redis
    cursor = "0"

    loop do
      cursor, keys = redis.with { |client| client.scan(cursor, match: "contents\/#{market}\/#{content_type}", count: 1000) }
      keys.each do |key|
        Rails.cache.delete(key)
      end
      break if cursor == "0"
    end
  end
end
