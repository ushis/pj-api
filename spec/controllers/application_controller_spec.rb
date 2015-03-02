require 'rails_helper'

describe ApplicationController do
  describe 'OPTIONS #options' do
    before { process(:options, 'OPTIONS', path: '/') }

    it { is_expected.to respond_with(:no_content) }

    describe 'body' do
      subject { response.body }

      it { is_expected.to be_blank }
    end

    describe 'Access-Control-Allow-Origin Header' do
      subject { response.headers['Access-Control-Allow-Origin'] }

      it { is_expected.to eq('*') }
    end

    describe 'Access-Control-Allow-Methods Header' do
      subject { response.headers['Access-Control-Allow-Methods'] }

      it { is_expected.to eq('GET, POST, PUT, PATCH, DELETE') }
    end

    describe 'Access-Control-Allow-Headers Header' do
      subject { response.headers['Access-Control-Allow-Headers'] }

      it { is_expected.to eq('Authorization, Content-Type') }
    end

    describe 'Access-Control-Max-Age Header' do
      subject { response.headers['Access-Control-Max-Age'] }

      it { is_expected.to eq('1728000') }
    end
  end
end
