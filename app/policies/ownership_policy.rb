class OwnershipPolicy < RelationshipPolicy
  class Scope < RelationshipPolicy::Scope
  end

  def create?
    user.owns?(record.car)
  end

  def destroy?
    user.owns?(record.car) && record.car.owners.count > 1
  end
end
