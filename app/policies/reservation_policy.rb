class ReservationPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(car: :users).where('users.id' => user)
    end
  end

  def show?
    user.owns_or_borrows?(record.car)
  end

  def create?
    user.owns_or_borrows?(record.car)
  end

  def update?
    user.owns?(record.car) ||
      (user == record.user) && user.owns_or_borrows?(record.car)
  end

  def destroy?
    user.owns?(record.car) ||
      (user == record.user) && user.owns_or_borrows?(record.car)
  end

  def accessible_associations
    [:user]
  end

  def accessible_attributes
    [:id, :starts_at, :ends_at, :created_at, :updated_at]
  end

  def permitted_attributes
    [:starts_at, :ends_at]
  end
end
