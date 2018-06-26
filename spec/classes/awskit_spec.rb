require 'spec_helper'

describe 'awskit' do
  let(:facts) do
    {
      'key_name'          => 'key_name',
      'region'            => 'eu-west-2',
      'availability_zone' => 'eu-west-2a',
      'subnet'            => 'my_subnet',
      'master_ip'         => '1.2.3.4',
      'wsus_ip'           => '1.2.3.4',
    }
  end

  it { is_expected.to compile }
end
