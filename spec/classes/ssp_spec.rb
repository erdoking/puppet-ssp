require 'spec_helper'

system_rootpath = '/var/ssp'
version_tag = 'v1.3'
local_config_file = "#{system_rootpath}/ssp_#{version_tag}/conf/config.inc.local.php"

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

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) do
        default_params
      end

      it { is_expected.to compile }

      context 'with pwd_special_chars' do
        let(:params) do
          default_params.merge(
            pwd_special_chars: '!',
          )
        end

        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$pwd_special_chars = "!";$}) }
      end

      context 'with pwd_forbidden_chars' do
        let(:params) do
          default_params.merge(
            pwd_forbidden_chars: '!',
          )
        end

        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$pwd_forbidden_chars = "!";$}) }
      end

      context 'with mail_smtp_auth' do
        let(:params) do
          default_params.merge(
            mail_smtp_auth: true,
            mail_smtp_user: 'mail_user',
            mail_smtp_pass: 'mail_secret',
          )
        end

        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$mail_smtp_user = 'mail_user';$}) }
        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$mail_smtp_pass = 'mail_secret';$}) }
      end

      context 'with login_forbidden_chars' do
        let(:params) do
          default_params.merge(
            login_forbidden_chars: '!',
          )
        end

        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$login_forbidden_chars = "!";$}) }
      end

      context 'with logo' do
        let(:params) do
          default_params.merge(
            logo: '/example/mylogo.png',
          )
        end

        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$logo = "/example/mylogo.png";$}) }
      end

      context 'with background_image' do
        let(:params) do
          default_params.merge(
            background_image: '/example/backgroud.png',
          )
        end

        it { is_expected.to contain_file(local_config_file.to_s).with_content(%r{^\$background_image = "/example/backgroud.png";$}) }
      end

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
