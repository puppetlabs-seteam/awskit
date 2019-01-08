require 'spec_helper'

describe 'awskit::create_gitlab' do
  let(:facts) { RSpec.configuration.default_facts }
  let(:params) do
    {
      'instance_name' => 'my-instance-name',
      'count'         => 1,
    }
  end

  it { is_expected.to compile }
  it {
    is_expected.to contain_awskit__create_host(params['instance_name'].to_s)
  }
  it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-gitlab") }
end
