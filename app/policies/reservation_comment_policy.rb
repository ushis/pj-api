class ReservationCommentPolicy < CommentPolicy

  def show?
    user.owns_or_borrows?(record.reservation.car)
  end

  def create?
    user.owns_or_borrows?(record.reservation.car)
  end

  def update?
    user.owns_or_borrows?(record.reservation.car) &&
      record.user == user &&
      record.created_at > 10.minutes.ago
  end

  def destroy?
    user.owns_or_borrows?(record.reservation.car) &&
      record.user == user &&
      record.created_at > 10.minutes.ago
  end
end
