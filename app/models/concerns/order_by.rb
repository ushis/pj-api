module OrderBy
  extend ActiveSupport::Concern

  included do
    class_attribute :order_by_attribute_values
    self.order_by_attribute_values = {}
  end

  module ClassMethods

    def order_by(attribute, direction=:asc)
      attribute = attribute.to_s
      direction = normalize_order_direction(direction)

      if !order_by_attribute_values.include?(attribute)
        return all
      end

      attr = order_by_attribute_values[attribute]

      if !attr.is_a?(Array)
        return order(attribute => direction)
      end

      table_name = reflections[attr[0].to_s].table_name
      includes(attr[0]).order("#{table_name}.#{attr[1]} #{direction}")
    end

    private

    def order_by_attributes(*attributes)
      attributes.each do |attr|
        if attr.is_a?(Hash)
          attr.each do |assoc, attr|
            order_by_attribute_values["#{assoc}.#{attr}"] = [assoc, attr]
          end
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
