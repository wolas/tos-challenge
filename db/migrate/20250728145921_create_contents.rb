class CreateContents < ActiveRecord::Migration[8.0]
  def change
    create_table :contents do |t|
      t.string :type, null: false
      t.string :original_title, null: false
      t.integer :year
      t.integer :duration_in_seconds
      t.integer :season_number
      t.integer :episode_number
      t.references :tv_show, foreign_key: { to_table: :contents }
      t.references :season, foreign_key: { to_table: :contents }
      t.references :channel, foreign_key: { to_table: :contents }
      t.jsonb :stream_info

      t.timestamps
    end
    add_index :contents, :type, if_not_exists: true
    add_index :contents, [:type, :tv_show_id], if_not_exists: true
    add_index :contents, [:type, :season_id], if_not_exists: true

    create_table :apps do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :apps, :name, unique: true, if_not_exists: true

    create_table :availabilities do |t|
      t.belongs_to :app, null: false, foreign_key: true
      t.belongs_to :content, null: false, foreign_key: true
      t.string :market, null: false
      t.jsonb :stream_info, default: {}

      t.timestamps
    end
    add_index :availabilities, [ :app_id, :content_id, :market ], unique: true, if_not_exists: true
    add_index :availabilities, :app_id, if_not_exists: true
    add_index :availabilities, :content_id, if_not_exists: true
    add_index :availabilities, :market, if_not_exists: true
  end
end
