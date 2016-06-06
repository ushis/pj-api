class CancelationPolicy < ApplicationPolicy

  def show?
    reservation_policy.show?
  end

  def create?
    reservation_policy.update?
  end

  def destroy?
    reservation_policy.update?
  end

  def accessible_associations
    [:user]
  end

  def accessible_attributes
    [:created_at, :updated_at]
  end

  private

  def reservation_policy
    ReservationPolicy.new(user, record.reservation)
  end
end
