class User < ActiveRecord::Base
  has_many :user_apps
  has_many :apps, through: :user_apps

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_create :generate_token

  private

  def generate_token
    loop do
      self.token = SecureRandom.hex
      break unless User.exists?(token: token)
    end
  end
end
