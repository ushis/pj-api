class RidePolicy < ApplicationPolicy

  def show?
    user.owns_or_borrows?(record.car)
  end

  def create?
    user.owns_or_borrows?(record.car)
  end

  def update?
    user.owns?(record.car) ||
      (user == record.user && user.borrows?(record.car))
  end

  def destroy?
    user.owns?(record.car) ||
      (user == record.user && user.borrows?(record.car))
  end

  def accessible_associations
    [:user]
  end

  def accessible_attributes
    [
      :id, :distance, :started_at, :ended_at, :comments_count,
      :created_at, :updated_at
    ]
  end

  def permitted_attributes
    [:distance, :started_at, :ended_at]
  end
end
