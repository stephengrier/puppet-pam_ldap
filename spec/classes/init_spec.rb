require 'spec_helper'
describe 'pam_ldap' do

  context 'with defaults for all parameters' do
    it { should contain_class('pam_ldap') }
  end
end
