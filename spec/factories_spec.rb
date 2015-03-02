require 'rails_helper'

FactoryGirl.factories.map(&:name).each do |name|
  describe "#{name} factory" do
    subject { build(name) }

    it { is_expected.to be_valid }
  end
end
