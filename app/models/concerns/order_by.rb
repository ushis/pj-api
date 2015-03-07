module OrderBy
  extend ActiveSupport::Concern

  included do
    class_attribute :order_by_attribute_values
    self.order_by_attribute_values = {}
  end

  module ClassMethods

    def order_by(attribute, direction=:asc)
      attribute = attribute.to_s

      if !order_by_attribute_values.key?(attribute)
        return all
      end

      attribute = order_by_attribute_values[attribute]
      direction = normalize_order_direction(direction)

      if attribute.is_a?(Array)
        assoc = attribute[0]
        attribute = attribute[1]
        table_name = reflections[assoc.to_s].table_name
        includes(assoc).order("#{table_name}.#{attribute} #{direction}")
      else
        order(attribute => direction)
      end
    end

    private

    def order_by_attributes(*attributes)
      attributes.each do |attr|
        if attr.is_a?(Hash)
          attr.each do |assoc, col|
            order_by_attribute_values["#{assoc}.#{col}"] = [assoc, col]
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
