class CarPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:users).where('users.id' => user)
    end
  end

  def show?
    user.owns_or_borrows?(record)
  end

  def create?
    user.owns?(record)
  end

  def update?
    user.owns?(record)
  end

  def destroy?
    user.owns?(record)
  end

  def accessible_associations
    [:position]
  end

  def accessible_attributes
    [
      :id, :name, :mileage,
      :rides_count, :owners_count, :borrowers_count,
      :created_at, :updated_at
    ]
  end

  def permitted_attributes
    [:name]
  end
end
