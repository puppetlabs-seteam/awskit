require 'spec_helper'

describe 'awskit::create_master' do
  let(:params) do
    {
      'instance_type' => 'my_instance_type',
      'user_data'     => 'my_user_data',
      'count'         => 1,
      'instance_name' => 'awskit-pm',
    }
  end

  it { is_expected.to compile }
  it { is_expected.to have_awskit__create_host_resource_count(1) }
  it {
    is_expected.to contain_awskit__create_host(params['instance_name']).with(
      'instance_type' => params['instance_type'],
      'user_data'     => params['user_data'],
      'public_ip'     => '1.2.3.4', # from hiera awskit::master_ip
    )
  }
end
