class UserPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    true
  end

  def update?
    user == record
  end

  def destroy?
    user == record
  end

  def accessible_attributes
    [:id, :username].tap do |attrs|
      if user == record
        attrs.concat([:email, :time_zone, :created_at, :updated_at, :access_token])
      end
    end
  end

  def permitted_attributes
    [:email, :time_zone, :password, :password_confirmation].tap do |attrs|
      attrs << :username if !record.persisted?
    end
  end
end
