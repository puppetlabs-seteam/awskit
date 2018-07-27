require 'spec_helper'

describe 'awskit' do
  let(:facts) { {'user' => 'foouser'} }

  it { is_expected.to compile }
  it { is_expected.to contain_ec2_securitygroup('foouser-awskit-master') }
  it { is_expected.to contain_ec2_securitygroup('foouser-awskit-agent') }
end
