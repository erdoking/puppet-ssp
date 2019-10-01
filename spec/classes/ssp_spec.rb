require 'spec_helper'

describe 'ssp' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          system_owner: 'foo',
          ldap_binddn: 'cn=manager,dc=example,dc=com',
          ldap_bindpw: 'secret',
          ldap_base: 'dc=example,dc=com',
          ldap_whochange_pw: 'user',
        }
      end

      it { is_expected.to compile }
    end
  end
end
