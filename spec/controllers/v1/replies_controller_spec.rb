require 'rails_helper'

describe V1::RepliesController do
  describe 'POST #create' do
    before { post :create, params: params }

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

    let(:message) { SecureRandom.uuid }

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

    context 'with missing recipient' do
      let(:recipient) { nil }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with an error' do
        expect(json[:details][:recipient]).to be_present
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

    context 'with non existing user' do
      let(:user) { build(:user, id: -1) }

      let(:record) { create(:car) }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with an error' do
        expect(json[:details][:recipient]).to be_present
      end
    end

    context 'with non existing record' do
      let(:record) { build(:car, id: -1) }

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

        let(:sample) { subject.sample }

        let(:sample_reply_to) { sample.reply_to.first }

        let(:sample_reply_address) { ReplyAddress.decode(sample_reply_to) }

        let(:sample_message_id) { sample.message_id }

        let(:sample_in_reply_to) { sample.in_reply_to }

        let(:sample_references) { sample.references }

        let(:sample_from) { sample.header['From'].to_s }

        let(:expected_from) do
          Mail::Address.new(ENV['MAIL_FROM']).tap do |address|
            address.display_name = user.username
          end.to_s
        end

        let(:sample_recipient) do
          (owners + commenters).find { |u| u.email == sample.to.first }
        end

        let(:comment) { Comment.order(created_at: :desc).first }

        its(:length) { is_expected.to eq(4) }

        it 'sends an email to all owners and commenters' do
          expect(subject.map(&:to).flatten).to \
            match_array((owners + commenters).map(&:email))
        end

        it 'sends a comment mail' do
          expect(sample.subject).to include('Re: ')
        end

        it 'sets the correct car name' do
          expect(sample.subject).to include(record.name)
        end

        it 'encodes the correct user in the Reply-To Header' do
          expect(sample_reply_address.user).to eq(sample_recipient)
        end

        it 'encodes the correct record in the Reply-To Header' do
          expect(sample_reply_address.record).to eq(record)
        end

        it 'sets the correct Message-Id header' do
          expect(sample_message_id).to eq(MessageID.new(record, comment).id)
        end

        it 'sets the correct In-Reply-To header' do
          expect(sample_in_reply_to).to eq(MessageID.new(record).id)
        end

        it 'sets the correct References header' do
          expect(sample_references).to eq(MessageID.new(record).id)
        end

        it 'sets the correct From header' do
          expect(sample_from).to eq(expected_from)
        end
      end
    end
  end
end
