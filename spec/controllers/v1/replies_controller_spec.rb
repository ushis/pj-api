require 'rails_helper'

describe V1::RepliesController do
  describe 'POST #create' do
    before { post :create, params }

    let(:params) do
      {
        mail: {
          recipient: recipient,
          message: {
            text: message
          }
        }
      }
    end

    let!(:recipient) { ReplyAddress.new(user, record).to_s }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { user.cars.sample }

    let(:message) { SecureRandom.hex(32) }

    context 'without params' do
      let(:params) { {} }

      it { is_expected.to respond_with(:unprocessable_entity) }
    end

    context 'with invalid message' do
      let(:message) { '  ' }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with an error' do
        expect(json[:details][:message]).to be_present
      end
    end

    context 'with invalid recipient' do
      let(:recipient) { 'invalid@' }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with an error' do
        expect(json[:details][:recipient]).to be_present
      end
    end

    context 'with unrelated user' do
      let(:record) { create(:car) }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with an error' do
        expect(json[:details][:recipient]).to be_present
      end
    end

    context 'with valid params' do
      let(:comment) { Comment.order(created_at: :desc).first }

      it { is_expected.to respond_with(:no_content) }

      it 'sets to correct author' do
        expect(comment.user).to eq(user)
      end

      it 'sets the correct car' do
        expect(comment.car).to eq(record)
      end

      it 'sets the correct comment' do
        expect(comment.comment).to eq(message)
      end

      describe 'emails' do
        let(:record) do
          create(:car, owners: [user] + owners, borrowers: borrowers, comments: comments)
        end

        let(:owners) { build_list(:user, 2) }

        let(:borrowers) { build_list(:user, 2) }

        let(:comments) { build_list(:car_comment, 2) }

        let(:commenters) { comments.map(&:user) }

        subject { ActionMailer::Base.deliveries }

        its(:length) { is_expected.to eq(4) }

        it 'sends an email to all owners and commenters' do
          expect(subject.map(&:to).flatten).to \
            match_array((owners + commenters).map(&:email))
        end

        it 'sends a comment mail' do
          expect(subject.first.subject).to include('comment')
        end

        it 'sets the correct car name' do
          expect(subject.first.subject).to include(record.name)
        end
      end
    end
  end
end
