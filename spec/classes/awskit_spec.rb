require 'spec_helper'

describe 'awskit' do
    let(:facts){ {
      :key_name => 'key_name',
      :region => 'eu-west-2',
      :availability_zone => 'eu-west-2a',
      :subnet => 'my_subnet',
      :master_ip => '1.2.3.4',
      :wsus_ip => '1.2.3.4',
    } }
    # on_supported_os.each do |os, os_facts|
    # context "on #{os}" do
    #   let(:facts) { os_facts }

      it { is_expected.to compile }
    # end
  # end
end
