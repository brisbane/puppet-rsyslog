require 'spec_helper'
describe 'rsyslog' do
  context 'with default values for all parameters' do
    it { should contain_class('rsyslog') }
  end
end
