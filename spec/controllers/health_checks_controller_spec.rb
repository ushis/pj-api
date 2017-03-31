require 'rails_helper'

describe HealthChecksController do
  describe 'GET #show' do
    context 'when everything is fine' do
      before { get :show }

      it 'responds with the systems status' do
        expect(json[:status]).to eq('ok')
      end

      it 'responds with the systems database component' do
        expect(json.dig(:components, :database)).to eq('ok')
      end
    end

    context 'with unhealthy database' do
      before { ActiveRecord::Base.remove_connection }

      before { get :show }

      after { ActiveRecord::Base.establish_connection }

      it 'responds with the systems status' do
        expect(json[:status]).to eq('critical')
      end

      it 'responds with the systems database component' do
        expect(json.dig(:components, :database)).to match(/\Acritical: .+\z/)
      end
    end
  end
end
