class Run < ApplicationRecord
  belongs_to :user
  belongs_to :contact
  validates :location, :end_time, :status, :user_id, :contact_id, :presence => true

end
