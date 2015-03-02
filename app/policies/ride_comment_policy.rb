class RideCommentPolicy < CommentPolicy
 class Scope < CommentPolicy::Scope
    def resolve
      scope.joins(ride: {car: :users}).where('users.id' => user)
    end
  end

  def show?
    user.owns_or_borrows?(record.ride.car)
  end

  def create?
    user.owns_or_borrows?(record.ride.car)
  end

  def update?
    user.owns_or_borrows?(record.ride.car) &&
      record.user == user &&
      record.created_at > 10.minutes.ago
  end

  def destroy?
    user.owns_or_borrows?(record.ride.car) &&
      record.user == user &&
      record.created_at > 10.minutes.ago
  end
end
