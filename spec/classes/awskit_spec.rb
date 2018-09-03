require 'spec_helper'

describe 'awskit' do
  let(:facts) { RSpec::configuration::default_facts }

  it { is_expected.to compile }
  it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-master") }
  it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-agent") }
end
