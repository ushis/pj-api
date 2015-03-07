module OrderBy
  extend ActiveSupport::Concern

  included do
    class_attribute :order_by_attribute_values
    self.order_by_attribute_values = Set.new
  end

  module ClassMethods

    def order_by(attribute, direction=:asc)
      attribute = attribute.to_s
      direction = normalize_order_direction(direction)

      if order_by_attribute_values.include?(attribute)
        order(attribute => direction)
      else
        all
      end
    end

    private

    def order_by_attributes(*attributes)
      attributes.each { |attr| order_by_attribute_values << attr.to_s }
    end

    def normalize_order_direction(direction)
      %w(asc desc).include?(direction.to_s.downcase) ? direction : :asc
    end
  end
end
