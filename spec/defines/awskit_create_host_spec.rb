require 'spec_helper'

describe 'awskit::create_host' do
  let(:title) { 'my_host' }
  let(:params) do
    {
      'ami'           => 'my_ami',
      'instance_type' => 'my_instance_type',
      'user_data'     => 'my_user_data',
    }
  end

  it { is_expected.to compile }
  it {
    is_expected.to contain_awskit__create_host(title).with(
      'ami'           => params['ami'],
      'instance_type' => params['instance_type'],
      'user_data'     => params['user_data'],
    )
  }
end
