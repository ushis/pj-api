class HealthCheckPolicy < ApplicationPolicy

  def show?
    true
  end

  def accessible_attributes
    [:status, :components]
  end
end
