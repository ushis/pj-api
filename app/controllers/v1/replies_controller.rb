class V1::RepliesController < V1::ApplicationController
  rescue_from ReplyAddress::InvalidAddress, with: :invalid_address
  rescue_from Pundit::NotAuthorizedError,   with: :invalid_address

  before_action :find_record

  # POST /v1/replies
  def create
    @reply = Reply.new(current_user, @record, message_param)
    authorize @reply

    if @reply.save
      CommentCreatedMailJob.perform_later(@reply.comment)
      head :no_content
    else
      render_error :unprocessable_entity, @reply.errors
    end
  end

  private

  # Finds the related record
  def find_record
    @record = reply_address.record
  end

  # Returns the current user
  def current_user
    @current_user ||= reply_address.user
  end

  # Returns the decoded recipient address
  def reply_address
    @reply_address ||= ReplyAddress.decode(recipient_param)
  end

  # Renders an 'invalid address' error
  def invalid_address
    render_error(:unprocessable_entity, {recipient: ['invalid address']})
  end

  # Returns the recipient parameter
  def recipient_param
    params.require(:mail).fetch(:recipient, nil)
  end

  # Returns the message parameter
  def message_param
    params.require(:mail).require(:message).fetch(:text, nil)
  end
end
