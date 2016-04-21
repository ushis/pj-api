require 'rails_helper'

describe V1::CommentsController do
  describe 'GET #index' do
    before { set_auth_header(token) }

    context 'with car id only' do
      let!(:comments) { create_list(:car_comment, 2, car: car) }

      before { get :index, car_id: car_id }

      let(:car_id) { car.id }

      let(:car) { create(:car) }

      context 'as anonymous user' do
        let(:token) { nil }

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'as logged in user' do
        let(:token) { user.access_token }

        let(:user) { create(:user, :with_owned_and_borrowed_cars) }

        context 'with invalid car id' do
          let(:car_id) { 0 }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is not related to the car' do
          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is related to the car' do
          let(:car) { user.cars.sample }

          it { is_expected.to respond_with(:success) }

          it 'responds with the cars comments' do
            expect(json[:comments]).to match_array(comments_json(comments))
          end
        end
      end
    end

    [:reservation, :ride].each do |parent_type|
      context "with #{parent_type} id" do
        let!(:comments) do
          create_list("#{parent_type}_comment", 2, parent_type => parent)
        end

        before { get :index, car_id: car_id, "#{parent_type}_id" => parent_id }

        let(:car_id) { car.id }

        let(:car) { create(:car) }

        let(:parent_id) { parent.id }

        let(:parent) { create(parent_type, car: car) }

        context 'as anonymous user' do
          let(:token) { nil }

          it { is_expected.to respond_with(:unauthorized) }
        end

        context 'as logged in user' do
          let(:token) { user.access_token }

          let(:user) { create(:user, :with_owned_and_borrowed_cars) }

          context 'with invalid car id' do
            let(:car_id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context "with invalid #{parent_type} id" do
            let(:parent_id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is not related to the car' do
            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is related to the car' do
            let(:car) { user.cars.sample }

            it { is_expected.to respond_with(:success) }

            it "responds with the #{parent_type}s comments" do
              expect(json[:comments]).to match_array(comments_json(comments))
            end
          end
        end
      end
    end
  end

  describe 'GET #show' do
    before { set_auth_header(token) }

    context 'with car id only' do
      before { get :show, car_id: car_id, id: id }

      let(:car_id) { car.id }

      let(:car) { create(:car) }

      let(:id) { comment.id }

      let(:comment) { create(:car_comment, car: car) }

      context 'as anonymous user' do
        let(:token) { nil }

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'as logged in user' do
        let(:token) { user.access_token }

        let(:user) { create(:user, :with_owned_and_borrowed_cars) }

        context 'with invalid car id' do
          let(:car_id) { 0 }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with invalid id' do
          let(:id) { 0 }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is not related to the car' do
          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is related to the car' do
          let(:car) { user.cars.sample }

          it { is_expected.to respond_with(:success) }

          it 'responds with the comment' do
            expect(json[:comment]).to eq(comment_json(comment))
          end
        end
      end
    end

    [:reservation, :ride].each do |parent_type|
      context "with #{parent_type} id" do
        before do
          get :show, car_id: car_id, "#{parent_type}_id" => parent_id, id: id
        end

        let(:car_id) { car.id }

        let(:car) { create(:car) }

        let(:parent_id) { parent.id }

        let(:parent) { create(parent_type, car: car) }

        let(:id) { comment.id }

        let(:comment) { create("#{parent_type}_comment", parent_type => parent) }

        context 'as anonymous user' do
          let(:token) { nil }

          it { is_expected.to respond_with(:unauthorized) }
        end

        context 'as logged in user' do
          let(:token) { user.access_token }

          let(:user) { create(:user, :with_owned_and_borrowed_cars) }

          context 'with invalid car id' do
            let(:car_id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'with invalid id' do
            let(:id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is not related to the car' do
            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is related to the car' do
            let(:car) { user.cars.sample }

            it { is_expected.to respond_with(:success) }

            it 'responds with the comment' do
              expect(json[:comment]).to eq(comment_json(comment))
            end
          end
        end
      end
    end
  end

  describe 'POST #create' do
    before { set_auth_header(token) }

    context 'with car id only' do
      before { post :create, params.merge(car_id: car_id) }

      let(:car_id) { car.id }

      let(:car) { create(:car) }

      context 'as anonymous user' do
        let(:token) { nil }

        let(:params) { {} }

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'as logged in user' do
        let(:token) { user.access_token }

        let(:user) { create(:user, :with_owned_and_borrowed_cars) }

        context 'with invalid car id' do
          let(:car_id) { 0 }

          let(:params) { {} }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is not related to the car' do
          let(:params) { {} }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is related to the car' do
          let(:car) { user.cars.sample }

          context 'without params' do
            let(:params) { {} }

            it { is_expected.to respond_with(:unprocessable_entity) }
          end

          context 'with invalid comment' do
            let(:params) do
              {
                comment: {
                  comment: nil
                }
              }
            end

            it { is_expected.to respond_with(:unprocessable_entity) }

            it 'responds with error details' do
              expect(json[:details][:comment]).to be_present
            end
          end

          context 'with valid params' do
            let(:params) do
              {
                comment: {
                  comment: SecureRandom.uuid
                }
              }
            end

            let(:comment) { CarComment.find(json[:comment][:id]) }

            it { is_expected.to respond_with(:created) }

            it 'responds with the comment' do
              expect(json[:comment]).to eq(comment_json(comment))
            end

            it 'sets the correct comment' do
              expect(comment.comment).to eq(params[:comment][:comment])
            end

            it 'sets the correct user' do
              expect(comment.user).to eq(user)
            end

            it 'sets the correct car' do
              expect(comment.car).to eq(car)
            end

            describe 'emails' do
              let(:car) do
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

              its(:length) { is_expected.to eq(4) }

              it 'sends an email to all owners and commenters' do
                expect(subject.map(&:to).flatten).to \
                  match_array((owners + commenters).map(&:email))
              end

              it 'sends a comment mail' do
                expect(sample.subject).to eq("Re: Discussion about #{car.name}")
              end

              it 'sets the correct car name' do
                expect(sample.subject).to include(car.name)
              end

              it 'encodes the correct user in the Reply-To header' do
                expect(sample_reply_address.user).to eq(sample_recipient)
              end

              it 'encodes the correct car in the Reply-To header' do
                expect(sample_reply_address.record).to eq(car)
              end

              it 'sets the correct Message-Id header' do
                expect(sample_message_id).to eq(MessageID.new(car, comment).id)
              end

              it 'sets the correct In-Reply-To header' do
                expect(sample_in_reply_to).to eq(MessageID.new(car).id)
              end

              it 'sets the correct References header' do
                expect(sample_references).to eq(MessageID.new(car).id)
              end

              it 'sets the correct From header' do
                expect(sample_from).to eq(expected_from)
              end
            end
          end
        end
      end
    end

    [:reservation, :ride].each do |parent_type|
      context "with #{parent_type} id" do
        before do
          post :create, params.merge(car_id: car_id, "#{parent_type}_id" => parent_id)
        end

        let(:car_id) { car.id }

        let(:car) { create(:car) }

        let(:parent_id) { parent.id }

        let(:parent) { create(parent_type, car: car) }

        context 'as anonymous user' do
          let(:token) { nil }

          let(:params) { {} }

          it { is_expected.to respond_with(:unauthorized) }
        end

        context 'as logged in user' do
          let(:token) { user.access_token }

          let(:user) { create(:user, :with_owned_and_borrowed_cars) }

          context 'with invalid car id' do
            let(:car_id) { 0 }

            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }
          end

          context "with invalid #{parent_type} id" do
            let(:parent_id) { 0 }

            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is not related to the car' do
            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is related to the car' do
            let(:car) { user.cars.sample }

            context 'without params' do
              let(:params) { {} }

              it { is_expected.to respond_with(:unprocessable_entity) }
            end

            context 'with invalid comment' do
              let(:params) do
                {
                  comment: {
                    comment: nil
                  }
                }
              end

              it { is_expected.to respond_with(:unprocessable_entity) }

              it 'responds with error details' do
                expect(json[:details][:comment]).to be_present
              end
            end

            context 'with valid params' do
              let(:params) do
                {
                  comment: {
                    comment: SecureRandom.uuid
                  }
                }
              end

              let(:comment) { parent.comments(true).find(json[:comment][:id]) }

              it { is_expected.to respond_with(:created) }

              it 'responds with the comment' do
                expect(json[:comment]).to eq(comment_json(comment))
              end

              it 'sets the correct comment' do
                expect(comment.comment).to eq(params[:comment][:comment])
              end

              it 'sets the correct user' do
                expect(comment.user).to eq(user)
              end

              describe 'emails' do
                let(:parent) { create(parent_type, car: car, comments: comments) }

                let(:car) { create(:car, owners: [user] + owners, borrowers: borrowers) }

                let(:owners) { build_list(:user, 2) }

                let(:borrowers) { build_list(:user, 2) }

                let(:comments) { build_list("#{parent_type}_comment", 2) }

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
                  (owners + commenters + [parent.user]).find { |u| u.email == sample.to.first }
                end

                its(:length) { is_expected.to eq(5) }

                it 'sends an email to all owners and commenters' do
                  expect(subject.map(&:to).flatten).to \
                    match_array((owners + commenters + [parent.user]).map(&:email))
                end

                it 'sends a comment mail' do
                  expect(sample.subject).to include('Re: ')
                end

                it 'sets the correct car name' do
                  expect(sample.subject).to include(car.name)
                end

                it 'encodes the correct user in the Reply-To Header' do
                  expect(sample_reply_address.user).to eq(sample_recipient)
                end

                it 'encodes the correct parent in the Reply-To Header' do
                  expect(sample_reply_address.record).to eq(parent)
                end

                it 'sets the correct Message-Id header' do
                  expect(sample_message_id).to eq(MessageID.new(car, parent, comment).id)
                end

                it 'sets the correct In-Reply-To header' do
                  expect(sample_in_reply_to).to eq(MessageID.new(car, parent).id)
                end

                it 'sets the correct References header' do
                  expect(sample_references).to eq(MessageID.new(car, parent).id)
                end

                it 'sets the correct From header' do
                  expect(sample_from).to eq(expected_from)
                end
              end
            end
          end
        end
      end
    end
  end

  describe 'PATCH #update' do
    before { set_auth_header(token) }

    context 'with car id only' do
      before { patch :update, params.merge(car_id: car_id, id: id) }

      let(:car_id) { car.id }

      let(:car) { create(:car) }

      let(:id) { comment.id }

      let(:comment) { create(:car_comment, car: car) }

      context 'as anonymous user' do
        let(:token) { nil }

        let(:params) { {} }

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'as logged in user' do
        let(:token) { user.access_token }

        let(:user) { create(:user, :with_owned_and_borrowed_cars) }

        context 'with invalid car id' do
          let(:car_id) { 0 }

          let(:params) { {} }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with invalid id' do
          let(:id) { 0 }

          let(:params) { {} }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is not related to the car' do
          let(:params) { {} }

          it { is_expected.to respond_with(:not_found) }

          context 'and wrote the comment' do
            let(:comment) { create(:car_comment, car: car, user: user) }

            it { is_expected.to respond_with(:not_found) }
          end
        end

        context 'who is related to the car' do
          let(:car) { user.cars.sample }

          context 'but did not write the comment' do
            let(:params) do
              {
                comment: {
                  comment: nil
                }
              }
            end

            it { is_expected.to respond_with(:forbidden) }
          end

          context 'and wrote the comment' do
            let(:comment) do
              create(:car_comment, car: car, user: user, created_at: created_at)
            end

            context 'more than 10 minutes ago' do
              let(:created_at) { (rand(100) + 11).minutes.ago }

              let(:params) do
                {
                  comment: {
                    comment: nil
                  }
                }
              end

              it { is_expected.to respond_with(:forbidden) }
            end

            context 'less than 10 minutes ago' do
              let(:created_at) { rand(10).minutes.ago }

              context 'without params' do
                let(:params) { {} }

                it { is_expected.to respond_with(:unprocessable_entity) }
              end

              context 'with invalid comment' do
                let(:params) do
                  {
                    comment: {
                      comment: nil
                    }
                  }
                end

                it { is_expected.to respond_with(:unprocessable_entity) }

                it 'responds with error details' do
                  expect(json[:details][:comment]).to be_present
                end
              end

              context 'with valid params' do
                let(:params) do
                  {
                    comment: {
                      comment: SecureRandom.uuid
                    }
                  }
                end

                it { is_expected.to respond_with(:success) }

                it 'responds with the comment' do
                  expect(json[:comment]).to eq(comment_json(comment.reload))
                end

                it 'sets the correct comment' do
                  expect(comment.reload.comment).to \
                    eq(params[:comment][:comment])
                end
              end
            end
          end
        end
      end
    end

    [:reservation, :ride].each do |parent_type|
      context "with #{parent_type} id" do
        before do
          patch :update, params.merge({
            car_id: car_id,
            "#{parent_type}_id" => parent_id,
            id: id
          })
        end

        let(:car_id) { car.id }

        let(:car) { create(:car) }

        let(:parent_id) { parent.id }

        let(:parent) { create(parent_type, car: car) }

        let(:id) { comment.id }

        let(:comment) { create("#{parent_type}_comment", parent_type => parent) }

        context 'as anonymous user' do
          let(:token) { nil }

          let(:params) { {} }

          it { is_expected.to respond_with(:unauthorized) }
        end

        context 'as logged in user' do
          let(:token) { user.access_token }

          let(:user) { create(:user, :with_owned_and_borrowed_cars) }

          context 'with invalid car id' do
            let(:car_id) { 0 }

            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }
          end

          context "with invalid #{parent_type} id" do
            let(:parent_id) { 0 }

            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'with invalid id' do
            let(:id) { 0 }

            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }
          end


          context 'who is not related to the car' do
            let(:params) { {} }

            it { is_expected.to respond_with(:not_found) }

            context 'and wrote the comment' do
              let(:comment) do
                create("#{parent_type}_comment", {
                  parent_type => parent,
                  user: user
                })
              end

              it { is_expected.to respond_with(:not_found) }
            end
          end

          context 'who is related to the car' do
            let(:car) { user.cars.sample }

            context 'but did not write the comment' do
              let(:params) do
                {
                  comment: {
                    comment: nil
                  }
                }
              end

              it { is_expected.to respond_with(:forbidden) }
            end

            context 'and wrote the comment' do
              let(:comment) do
                create("#{parent_type}_comment", {
                  parent_type => parent,
                  user: user,
                  created_at: created_at
                })
              end

              context 'more than 10 minutes ago' do
                let(:created_at) { (rand(100) + 11).minutes.ago }

                let(:params) do
                  {
                    comment: {
                      comment: nil
                    }
                  }
                end

                it { is_expected.to respond_with(:forbidden) }
              end

              context 'less than 10 minutes ago' do
                let(:created_at) { rand(10).minutes.ago }

                context 'without params' do
                  let(:params) { {} }

                  it { is_expected.to respond_with(:unprocessable_entity) }
                end

                context 'with invalid comment' do
                  let(:params) do
                    {
                      comment: {
                        comment: nil
                      }
                    }
                  end

                  it { is_expected.to respond_with(:unprocessable_entity) }

                  it 'responds with error details' do
                    expect(json[:details][:comment]).to be_present
                  end
                end

                context 'with valid params' do
                  let(:params) do
                    {
                      comment: {
                        comment: SecureRandom.uuid
                      }
                    }
                  end

                  it { is_expected.to respond_with(:success) }

                  it 'responds with the comment' do
                    expect(json[:comment]).to eq(comment_json(comment.reload))
                  end

                  it 'sets the correct comment' do
                    expect(comment.reload.comment).to \
                      eq(params[:comment][:comment])
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    context 'with car id only' do
      before { delete :destroy, car_id: car_id, id: id }

      let(:car_id) { car.id }

      let(:car) { create(:car) }

      let(:id) { comment.id }

      let(:comment) { create(:car_comment, car: car) }

      context 'as anonymous user' do
        let(:token) { nil }

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'as logged in user' do
        let(:token) { user.access_token }

        let(:user) { create(:user, :with_owned_and_borrowed_cars) }

        context 'with invalid car id' do
          let(:car_id) { 0 }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with invalid id' do
          let(:id) { 0 }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is not related to the car' do
          it { is_expected.to respond_with(:not_found) }

          context 'and wrote the comment' do
            let(:comment) { create(:car_comment, car: car, user: user) }

            it { is_expected.to respond_with(:not_found) }
          end
        end

        context 'who is related to the car' do
          let(:car) { user.cars.sample }

          context 'but did not write the comment' do
            it { is_expected.to respond_with(:forbidden) }
          end

          context 'and wrote the comment' do
            let(:comment) do
              create(:car_comment, car: car, user: user, created_at: created_at)
            end

            context 'more than 10 minutes ago' do
              let(:created_at) { (rand(100) + 11).minutes.ago }

              it { is_expected.to respond_with(:forbidden) }
            end

            context 'less than 10 minutes ago' do
              let(:created_at) { rand(10).minutes.ago }

              it { is_expected.to respond_with(:no_content) }

              it 'destroys the comment' do
                expect { comment.reload }.to \
                  raise_error(ActiveRecord::RecordNotFound)
              end
            end
          end
        end
      end
    end

    [:reservation, :ride].each do |parent_type|
      context "with #{parent_type} id" do
        before do
          delete :destroy, car_id: car_id, "#{parent_type}_id" => parent_id, id: id
        end

        let(:car_id) { car.id }

        let(:car) { create(:car) }

        let(:parent_id) { parent.id }

        let(:parent) { create(parent_type, car: car) }

        let(:id) { comment.id }

        let(:comment) { create("#{parent_type}_comment", parent_type => parent) }

        context 'as anonymous user' do
          let(:token) { nil }

          it { is_expected.to respond_with(:unauthorized) }
        end

        context 'as logged in user' do
          let(:token) { user.access_token }

          let(:user) { create(:user, :with_owned_and_borrowed_cars) }

          context 'with invalid car id' do
            let(:car_id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context "with invalid #{parent_type} id" do
            let(:parent_id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'with invalid id' do
            let(:id) { 0 }

            it { is_expected.to respond_with(:not_found) }
          end

          context 'who is not related to the car' do
            it { is_expected.to respond_with(:not_found) }

            context 'and wrote the comment' do
              let(:comment) do
                create("#{parent_type}_comment", {
                  parent_type => parent,
                  user: user
                })
              end

              it { is_expected.to respond_with(:not_found) }
            end

            context 'who is related to the car' do
              let(:car) { user.cars.sample }

              context 'but did not write the comment' do
                it { is_expected.to respond_with(:forbidden) }
              end

              context 'and wrote the comment' do
                let(:comment) do
                  create("#{parent_type}_comment", {
                    parent_type => parent,
                    user: user,
                    created_at: created_at
                  })
                end

                context 'more than 10 minutes ago' do
                  let(:created_at) { (rand(100) + 11).minutes.ago }

                  it { is_expected.to respond_with(:forbidden) }
                end

                context 'less than 10 minutes ago' do
                  let(:created_at) { rand(10).minutes.ago }

                  it { is_expected.to respond_with(:no_content) }

                  it 'destroys the comment' do
                    expect { comment.reload }.to \
                      raise_error(ActiveRecord::RecordNotFound)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
