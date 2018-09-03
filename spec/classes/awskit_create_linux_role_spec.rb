require 'spec_helper'

describe 'awskit::create_linux_role' do
  let(:params) do
    {
      'role'          => 'my-role',
      'user_data'     => 'my-user_data',
      'instance_name' => 'my-instance-name',
      'instance_type' => 'my-instance-type',
      'count'         => 1,
    }
  end

  let(:title) { "#{params['instance_name']}-#{params['role']}" }

  it { is_expected.to compile }

  context 'count => 1' do
    it {
      # binding.pry
      is_expected.to contain_awskit__create_host("#{title}-1")
    }
  end

  context 'count => 2' do
    let(:params) do
      super().merge('count' => '2')
    end

    it {
      # binding.pry
      is_expected.to contain_awskit__create_host("#{title}-1")
      is_expected.to contain_awskit__create_host("#{title}-2")
    }
  end
end
