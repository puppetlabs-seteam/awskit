require 'spec_helper'

let(:facts) { RSpec.configuration.default_facts }

describe 'awskit::create_wsus' do
  it { is_expected.to compile }
  it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-wsus") }
end
