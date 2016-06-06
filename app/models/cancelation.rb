class Cancelation < ActiveRecord::Base
  belongs_to :reservation, inverse_of: :cancelation, required: true
  belongs_to :user,        inverse_of: :cancelations
end
