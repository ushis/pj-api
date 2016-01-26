class ApplicationSerializer < ActiveModel::Serializer

  def attributes
    super.slice(*policy.accessible_attributes)
  end

  def associations(include_tree=DEFAULT_INCLUDE_TREE)
    super(include_tree).slice(*policy.accessible_associations)
  end

  private

  def policy
    @policy ||= Pundit::PolicyFinder.new(object).policy.new(scope, object)
  end
end
