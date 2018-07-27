require 'spec_helper'

describe 'awskit::create_discovery' do

  let(:facts) { {'user' => 'foouser'} }
  
  it { is_expected.to compile }
  it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-disco-cd4pe") }

end
