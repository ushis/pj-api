class Cancelation < ActiveRecord::Base
  belongs_to :reservation, inverse_of: :cancelation
  belongs_to :user,        inverse_of: :cancelations, optional: true
end
