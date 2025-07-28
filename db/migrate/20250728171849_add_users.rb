class AddUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :username, null: false
      t.string :token, null: false

      t.timestamps
    end
    add_index :users, :username, unique: true, if_not_exists: true
    add_index :users, :email, unique: true, if_not_exists: true
    add_index :users, :token, unique: true, if_not_exists: true

    create_table :user_contents do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :content, null: false, foreign_key: true
      t.integer :watched_time
    end
    add_index :user_contents, [:user_id, :content_id], unique: true, if_not_exists: true

    create_table :user_apps do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :app, null: false, foreign_key: true
      t.integer :position
    end
    add_index :user_apps, [:user_id, :app_id], unique: true, if_not_exists: true
  end
end
