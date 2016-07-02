class Reply
  extend ActiveModel::Naming

  attr_reader :user, :record, :message

  def initialize(user, record, message)
    @user = user
    @record = record
    @message = message
  end

  def comment
    @comment ||= record.comments.build(user: user, comment: message)
  end

  def save
    comment.save
  end

  def errors
    ActiveModel::Errors.new(self).tap do |errors|
      errors.add(:message, comment.errors[:comment])
    end
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options={})
    attr
  end

  def self.lookup_ancestors
    [self]
  end
end
