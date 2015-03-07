class BorrowershipPolicy < RelationshipPolicy

  def create?
    user.owns?(record.car)
  end

  def destroy?
    user.owns?(record.car) || record.user == user
  end
end
