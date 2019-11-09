require 'spec_helper'

describe 'ssp' do
  let(:default_params) do
    {
      system_owner: 'foo',
      ldap_binddn: 'cn=manager,dc=example,dc=com',
      ldap_bindpw: 'secret',
      ldap_base: 'dc=example,dc=com',
      ldap_whochange_pw: 'user',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        default_params
      end

      it { is_expected.to compile }

      context 'with buggy change settings' do
        let(:params) do
          default_params.merge(
            default_action: 'change',
            use_change: false,
          )
        end

        it { is_expected.to compile.and_raise_error(%r{\$use_change is set to false and \$default_action is set to "change"}) }
      end

      context 'with buggy token settings' do
        let(:params) do
          default_params.merge(
            default_action: 'sendtoken',
            use_tokens: false,
          )
        end

        it { is_expected.to compile.and_raise_error(%r{\$use_tokens is set to false and \$default_action is set to "sendtoken"}) }
      end
    end
  end
end
