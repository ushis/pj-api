class V1::ApplicationController < ApplicationController

  private

  # Returns a parameter as ActiveSupport::TimeWithZone or nil
  def datetime_param(key)
    datetime_params[key] ||= Time.zone.parse(params[key].to_s)
  end

  # Returns a hash of all parsed datetime parameters
  def datetime_params
    @datetime_params ||= {}
  end
end
