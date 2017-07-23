class Contact < ApplicationRecord
  has_one :run
  validates :contact_name, :contact_phone_number, :presence => true

end
