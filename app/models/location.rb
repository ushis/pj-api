class Location < ActiveRecord::Base
  belongs_to :user, inverse_of: :locations, optional: true
  belongs_to :car,  inverse_of: :location

  validates :latitude,  presence: true, numericality: {greater_than: -90, less_than: 90}
  validates :longitude, presence: true, numericality: {greater_than: -180, less_than: 180}
end
