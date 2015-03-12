module TimeZoneAttributes
  extend ActiveSupport::Concern

  private

  def find_time_zone(name)
    ActiveSupport::TimeZone[normalize_time_zone_name(name)] || Time.zone
  rescue ArgumentError
    Time.zone
  end

  def normalize_time_zone_name(name)
    Integer(name)
  rescue ArgumentError, TypeError
    name
  end

  public

  module ClassMethods

    def time_zone_attributes(*attributes)
      attributes.each do |attr|
        define_method("#{attr}=") do |zone|
          case zone
          when nil
            super(nil)
          when ActiveSupport::TimeZone
            super(zone.tzinfo.name)
          else
            super(find_time_zone(zone).tzinfo.name)
          end
        end

        define_method(attr) do
          find_time_zone(super())
        end
      end
    end
  end
end
