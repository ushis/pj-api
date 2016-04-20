class ReplyPolicy < ApplicationPolicy

  def create?
    comment_policy.create?
  end

  private

  def comment_policy
    @comment_policy ||= Pundit::PolicyFinder
      .new(record.comment).policy.new(user, record.comment)
  end
end
