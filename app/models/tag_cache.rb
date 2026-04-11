class TagCache
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,   type: String
  field :quotes, type: Array, default: []

  index({ name: 1 }, { unique: true })

  validates :name, presence: true, uniqueness: true
end
