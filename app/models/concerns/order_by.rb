module OrderBy
  extend ActiveSupport::Concern

  included do
    class_attribute :order_by_attribute_values
    self.order_by_attribute_values = {}
  end

  module ClassMethods

    def order_by(attribute, direction=:asc)
      attribute = attribute.to_s

      if order_by_attribute_values.key?(attribute)
        attribute = order_by_attribute_values[attribute]
        direction = normalize_order_direction(direction)
        order(attribute => direction)
      else
        all
      end
    end

    private

    def order_by_attributes(*attributes)
      attributes.each do |attr|
        if attr.is_a?(Hash)
          order_by_attribute_values.merge(attr.stringify_keys)
        else
          order_by_attribute_values[attr.to_s] = attr
        end
      end
    end

    def normalize_order_direction(direction)
      %w(asc desc).include?(direction.to_s.downcase) ? direction : :asc
    end
  end
end
