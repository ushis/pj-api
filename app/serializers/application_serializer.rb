class ApplicationSerializer < ActiveModel::Serializer

  def attributes
    super.slice(*policy.accessible_attributes)
  end

  def associations
    super.slice(*policy.accessible_associations)
  end

  private

  def policy
    @policy ||= Pundit::PolicyFinder.new(object).policy.new(scope, object)
  end
end
