class ContentJsonIndexQuery
  def initialize(market, type = nil)
    @market = market
    @type = type
  end

  def call
    ctes = []
    json_keys = []

    if @type.blank? || @type == "movies"
      ctes << movies_query
      json_keys << "'movies', COALESCE((SELECT json_agg(movie_json) FROM movie_data), '[]'::json)"
    end

    if @type.blank? || @type == "tv_shows"
      ctes << tv_shows_query
      json_keys << "'tv_shows', COALESCE((SELECT json_agg(tv_show_json) FROM tv_show_data), '[]'::json)"
    end

    if @type.blank? || @type == "channels"
      ctes << channels_query
      json_keys << "'channels', COALESCE((SELECT json_agg(channel_json) FROM channel_data), '[]'::json)"
    end

    query = <<~SQL
      WITH #{ctes.join(', ')}
      SELECT json_build_object(#{json_keys.join(', ')}) AS result;
    SQL

    sanitized_query = ActiveRecord::Base.sanitize_sql_array([ query, { market: @market } ])
    result = ActiveRecord::Base.connection.select_one(sanitized_query)
    JSON.parse(result["result"])
  end

  def movies_query
    <<~SQL
      movie_data AS (
        SELECT
          c.id,
          json_build_object(
            'original_title', c.original_title,
            'year', c.year,
            'duration_in_seconds', c.duration_in_seconds,
            'type', c.type,
            'availabilities', (
              SELECT json_agg(
                json_build_object(
                  'app', a.name,
                  'market', av.market
                )
              )
              FROM availabilities av
              JOIN apps a ON av.app_id = a.id
              WHERE av.content_id = c.id
                AND av.market = :market
            )
          ) AS movie_json
        FROM contents c
        WHERE c.type = 'Movie'
          AND EXISTS (
            SELECT 1
            FROM availabilities av
            WHERE av.content_id = c.id
              AND av.market = :market
          )
      )
    SQL
  end

  def tv_shows_query
    <<~SQL
      tv_show_data AS (
        SELECT
          c.id,
          json_build_object(
            'original_title', c.original_title,
            'year', c.year,
            'duration_in_seconds', c.duration_in_seconds,
            'type', c.type,
            'availabilities', (
              SELECT json_agg(
                json_build_object(
                  'app', a.name,
                  'market', av.market
                )
              )
              FROM availabilities av
              JOIN apps a ON av.app_id = a.id
              WHERE av.content_id = c.id
                AND av.market = :market
            ),
            'seasons', COALESCE((
              SELECT json_agg(
                json_build_object(
                  'original_title', s.original_title,
                  'number', s.season_number,
                  'year', s.year,
                  'duration_in_seconds', s.duration_in_seconds,
                  'type', s.type,
                  'availabilities', (
                    SELECT json_agg(
                      json_build_object(
                        'app', a2.name,
                        'market', av2.market
                      )
                    )
                    FROM availabilities av2
                    JOIN apps a2 ON av2.app_id = a2.id
                    WHERE av2.content_id = s.id
                      AND av2.market = :market
                  )
                )
              )
              FROM contents s
              WHERE s.type = 'Season'
                AND s.tv_show_id = c.id
                AND EXISTS (
                  SELECT 1
                  FROM availabilities av2
                  WHERE av2.content_id = s.id
                    AND av2.market = :market
                )
            ), '[]'::json),
            'episodes', COALESCE((
              SELECT json_agg(
                json_build_object(
                  'original_title', e.original_title,
                  'number', e.episode_number,
                  'season_number', s.season_number,
                  'year', e.year,
                  'duration_in_seconds', e.duration_in_seconds,
                  'type', e.type
                )
              )
              FROM contents e
              JOIN contents s ON e.season_id = s.id
              WHERE e.type = 'Episode'
                AND s.type = 'Season'
                AND s.tv_show_id = c.id
            ), '[]'::json)
          ) AS tv_show_json
        FROM contents c
        WHERE c.type = 'TvShow'
          AND EXISTS (
            SELECT 1
            FROM availabilities av
            WHERE av.content_id = c.id
              AND av.market = :market
          )
      )
    SQL
  end

  def channels_query
    <<~SQL
      channel_data AS (
        SELECT
          c.id,
          json_build_object(
            'original_title', c.original_title,
            'type', c.type,
            'availabilities', (
              SELECT json_agg(
                json_build_object(
                  'app', a.name,
                  'market', av.market,
                  'stream_info', av.stream_info
                )
              )
              FROM availabilities av
              JOIN apps a ON av.app_id = a.id
              WHERE av.content_id = c.id
                AND av.market = :market
            ),
            'channel_programs', COALESCE((
              SELECT json_agg(
                json_build_object(
                  'original_title', cp.original_title,
                  'type', cp.type,
                  'availabilities', (
                    SELECT json_agg(
                      json_build_object(
                        'app', a2.name,
                        'market', av2.market
                      )
                    )
                    FROM availabilities av2
                    JOIN apps a2 ON av2.app_id = a2.id
                    WHERE av2.content_id = cp.id
                      AND av2.market = :market
                  )
                )
              )
              FROM contents cp
              WHERE cp.type = 'ChannelProgram'
                AND cp.channel_id = c.id
                AND EXISTS (
                  SELECT 1
                  FROM availabilities av2
                  WHERE av2.content_id = cp.id
                    AND av2.market = :market
                )
            ), '[]'::json)
          ) AS channel_json
        FROM contents c
        WHERE c.type = 'Channel'
          AND EXISTS (
            SELECT 1
            FROM availabilities av
            WHERE av.content_id = c.id
              AND av.market = :market
          )
      )
    SQL
  end
end
