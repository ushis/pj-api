class ApplicationPolicy < Struct.new(:user, :record)

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def accessible_associations
    []
  end

  def accessible_attributes
    []
  end

  def permitted_attributes
    []
  end
end
