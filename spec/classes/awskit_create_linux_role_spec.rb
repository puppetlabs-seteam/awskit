require 'spec_helper'

describe 'awskit::create_linux_role' do
  it { is_expected.to compile }

  let(:params) do
    {
      'role'          => 'my_role',
      'user_data'     => 'my_user_data',
      'instance_name' => 'my_instance_name',
      'instance_type' => 'my_instance_type',
      'user_data'     => 'my_user_data',
      'count'         => 3,
    }
  end

  let(:title) { "#{params['instance_name']}-#{params['role']}-3" }

  it {
    is_expected.to contain_awskit__create_host(title).with(
      'role'          => params['role'],
      'user_data'     => params['user_data'],
      'instance_type' => params['instance_type'],
      'user_data'     => params['user_data'],
    )
  }

end
