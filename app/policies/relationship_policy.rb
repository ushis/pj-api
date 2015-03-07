class RelationshipPolicy < ApplicationPolicy

  def show?
    user.owns_or_borrows?(record.car)
  end

  def accessible_associations
    [:user]
  end

  def accessible_attributes
    [:id, :created_at, :updated_at]
  end

  def permitted_attributes
    [:user_id]
  end
end
