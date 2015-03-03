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
          it { is_expected.to respond_with(:success) }

          it 'responds with an empty array' do
            expect(json[:comments]).to be_empty
          end
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
            it { is_expected.to respond_with(:success) }

            it 'responds with an empty array' do
              expect(json[:comments]).to be_empty
            end
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
          it { is_expected.to respond_with(:forbidden) }
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
            it { is_expected.to respond_with(:forbidden) }
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
          let(:params) do
            {
              comment: {
                comment: nil
              }
            }
          end

          it { is_expected.to respond_with(:forbidden) }
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
                  comment: SecureRandom.hex(32)
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
            let(:params) do
              {
                comment: {
                  comment: nil
                }
              }
            end

            it { is_expected.to respond_with(:forbidden) }
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
                    comment: SecureRandom.hex(32)
                  }
                }
              end

              let(:comment) { parent.comments.find(json[:comment][:id]) }

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
          let(:params) do
            {
              comment: {
                comment: nil
              }
            }
          end

          it { is_expected.to respond_with(:forbidden) }

          context 'and wrote the comment' do
            let(:comment) { create(:car_comment, car: car, user: user) }

            it { is_expected.to respond_with(:forbidden) }
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
                      comment: SecureRandom.hex(32)
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
            let(:params) do
              {
                comment: {
                  comment: nil
                }
              }
            end

            it { is_expected.to respond_with(:forbidden) }

            context 'and wrote the comment' do
              let(:comment) do
                create("#{parent_type}_comment", {
                  parent_type => parent,
                  user: user
                })
              end

              it { is_expected.to respond_with(:forbidden) }
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
                        comment: SecureRandom.hex(32)
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
          it { is_expected.to respond_with(:forbidden) }

          context 'and wrote the comment' do
            let(:comment) { create(:car_comment, car: car, user: user) }

            it { is_expected.to respond_with(:forbidden) }
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
            it { is_expected.to respond_with(:forbidden) }

            context 'and wrote the comment' do
              let(:comment) do
                create("#{parent_type}_comment", {
                  parent_type => parent,
                  user: user
                })
              end

              it { is_expected.to respond_with(:forbidden) }
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
