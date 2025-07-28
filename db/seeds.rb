sample_number = ENV['SAMPLE_DATA'].to_i.zero? ? 100 : ENV['SAMPLE_DATA'].to_i

years = (50.years.ago.year..1.year.ago.year).to_a

app_names = %i[netflix prime_video hbo_max disney]
print "Creating apps..."
@apps = app_names.map do |app|
  App.find_or_create_by!(name: app).id
end
puts "Done!"

def create_availabilities(contents)
  print "\tCreating availabilities..."
  markets = %i[gb es us ca it]
  availability_columns = %i[content_id app_id market]
  availability_values = []
  contents.each do |content|
    next if content.availabilities.present?

    rand(1..4).times do
      availability_values << [ content.id, @apps.sample, markets.sample ]
    end
  end
  Availability.import availability_columns, availability_values.uniq
  puts "Done!"
end

# content_columns = %i[original_title year duration_in_seconds episode_number season_number schedule_start_time schedule_end_time stream_info parent_id season_id]

print "Creating #{sample_number} movies..."
movie_values = []
content_columns = %i[original_title year duration_in_seconds]
sample_number.times do
  movie_values << [ Faker::Movie.title, years.sample, rand(1000..20000) ]
end
movie_ids = Movie.import!(content_columns, movie_values).ids
puts "Done!"
create_availabilities(Movie.find(movie_ids))

print "Creating #{sample_number} TV shows..."
content_columns = %i[original_title year]
tv_shows_values = []
sample_number.times do
  tv_shows_values << [ Faker::TvShows.constants.sample.to_s.underscore.humanize, years.sample ]
end
tv_show_ids = TvShow.import!(content_columns, tv_shows_values).ids
puts "Done!"
create_availabilities(TvShow.find(tv_show_ids))

print "\tCreating seasons for each show..."
content_columns = %i[original_title year season_number tv_show_id]
season_values = []
tv_show_ids.each do |tv_show_id|
  rand(1..10).times do |index|
    season_values << [ "Season #{index + 1}", years.sample, index + 1, tv_show_id ]
  end
end
season_ids = Season.import!(content_columns, season_values).ids
puts "Done!"
create_availabilities(Season.find(season_ids))

print "\tCreating episodes for each season..."
content_columns = %i[original_title year episode_number duration_in_seconds season_id]
episode_values = []
season_ids.each do |season_id|
  rand(1..10).times do |index|
    episode_values << [ "Episode #{index + 1}", years.sample, index + 1, rand(1000..20000), season_id ]
  end
end
Episode.import! content_columns, episode_values
puts "Done!"

print "Creating  #{sample_number} channels..."
channel_values = []
content_columns = %i[original_title]
sample_number.times do
  channel_values << [ Faker::Game.title ]
end
channel_ids = Channel.import!(content_columns, channel_values).ids
puts "Done!"
create_availabilities(Channel.find(channel_ids))

print "\tCreating programs for each channel..."
content_columns = %i[original_title channel_id]
chanel_program_values = []
channel_ids.each do |channel_id|
  rand(1..10).times do |index|
    chanel_program_values << [ "Program #{index + 1}", channel_id ]
  end
end
chanel_program_ids = ChannelProgram.import!(content_columns, chanel_program_values).ids
puts "Done!"
create_availabilities(ChannelProgram.find(chanel_program_ids))
