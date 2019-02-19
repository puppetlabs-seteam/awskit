require 'spec_helper'
require 'hiera'

describe 'awskit::create_master' do
  let(:params) do
    {
      'instance_type' => 'my_instance_type',
      'count'         => 1,
      'instance_name' => 'my-instance-name',
    }
  end

  let(:facts) { RSpec.configuration.default_facts }

  it { is_expected.to compile }
  it { is_expected.to have_awskit__create_host_resource_count(1) }
  it {
    is_expected.to contain_awskit__create_host(params['instance_name']).with(
      'instance_type' => params['instance_type'],
      'public_ip'     => '1.2.3.4', # from hiera awskit::master_ip
    )
  }

  it { is_expected.to contain_ec2_elastic_ip('1.2.3.4') } # from hiera awskit::master_ip

  it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-master") }
end
