require 'spec_helper'

describe 'awskit' do
  it { is_expected.to compile }
  it { is_expected.to contain_ec2_securitygroup('awskit-master') }
  it { is_expected.to contain_ec2_securitygroup('awskit-agent') }
end
