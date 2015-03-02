class Position < ActiveRecord::Base
  belongs_to :car, inverse_of: :position, required: true

  validates :latitude,  presence: true, numericality: {greater_than: -90, less_than: 90}
  validates :longitude, presence: true, numericality: {greater_than: -180, less_than: 180}
end
