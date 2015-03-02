class BorrowershipPolicy < RelationshipPolicy
  class Scope < RelationshipPolicy::Scope
  end

  def create?
    user.owns?(record.car)
  end

  def destroy?
    user.owns?(record.car) || record.user == user
  end
end
