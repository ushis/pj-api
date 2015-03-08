class LocationPolicy < ApplicationPolicy

  def show?
    user.owns_or_borrows?(record.car)
  end

  def create?
    user.owns_or_borrows?(record.car)
  end

  def update?
    user.owns_or_borrows?(record.car)
  end

  def destroy?
    user.owns_or_borrows?(record.car)
  end

  def accessible_associations
    [:user]
  end

  def accessible_attributes
    [:latitude, :longitude, :created_at, :updated_at]
  end

  def permitted_attributes
    [:latitude, :longitude]
  end
end
