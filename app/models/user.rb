class User < ApplicationRecord
  has_many :runs
  validates :username, :presence => true, :uniqueness => true

end
