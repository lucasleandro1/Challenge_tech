class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :registerable, :validatable

  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :access_token,       type: String

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  index({ email: 1 }, { unique: true })
  index({ access_token: 1 })

  def generate_access_token!
    self.access_token = SecureRandom.hex(24)
    save!
    access_token
  end
end
