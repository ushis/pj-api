class CommentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def accessible_associations
    [:user]
  end

  def accessible_attributes
    [:id, :comment, :created_at, :updated_at]
  end

  def permitted_attributes
    [:comment]
  end
end
