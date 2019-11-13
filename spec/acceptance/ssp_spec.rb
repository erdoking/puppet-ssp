require 'spec_helper_acceptance'

ipa_ip = fact_on('ipa', 'networking.ip')
ssp_domain = fact('networking.domain')
system_rootpath = '/var/ssp'
version_tag = 'v1.3'
local_config_file = "#{system_rootpath}/ssp_#{version_tag}/conf/config.inc.local.php"

describe 'ssp class' do
  context 'with minimal parameters' do
    it 'applies idempotently' do
      pp = %(
        class { 'ssp' :
          system_owner      => 'ssp',
          ldap_binddn       => 'uid=bindssp,cn=sysaccounts,cn=etc,dc=example,dc=com',
          ldap_bindpw       => 'bindpw',
          ldap_base         => 'cn=users,cn=accounts,dc=example,dc=com',
          mail_from         => 'admin@example.com',
          manage_git        => true,
          ldap_url          => ['ldap://#{ipa_ip}'],
        }
      )

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('curl -c /tmp/passwd-change -d "login=jsmith" -d "oldpassword=oldsecret" -d "newpassword=newsecret" -d "confirmpassword=newsecret" http://localhost') do
      its(:stdout) { is_expected.to match %r{Your password was changed} }
    end

    describe file(local_config_file.to_s) do
      it { is_expected.to be_file }
      its(:content) { is_expected.not_to match %r{^$pwd_min_length = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_max_length = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_min_lower = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_min_upper = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_min_digit = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_min_special = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_no_reuse = false;} }
      its(:content) { is_expected.not_to match %r{^$pwd_diff_login = true;} }
      its(:content) { is_expected.not_to match %r{^$pwd_complexity = 0;} }
      its(:content) { is_expected.not_to match %r{^$pwd_show_policy = "never";} }
      its(:content) { is_expected.not_to match %r{^$pwd_show_policy_pos = "above";} }
      its(:content) { is_expected.not_to match %r{^$pwd_no_special_at_ends = false;} }
      its(:content) { is_expected.not_to match %r{^$default_action = "change";} }
      its(:content) { is_expected.not_to match %r{^$use_change = true;} }
      its(:content) { is_expected.not_to match %r{^$who_change_password = "user";} }
      its(:content) { is_expected.not_to match %r{^$change_sshkey = false;} }
      its(:content) { is_expected.not_to match %r{^$change_sshkey_attribute = "sshPublicKey";} }
      its(:content) { is_expected.not_to match %r{^$who_change_sshkey = "user";} }
      its(:content) { is_expected.not_to match %r{^$notify_on_sshkey_change = false;} }
      its(:content) { is_expected.not_to match %r{^$use_tokens = true;} }
      its(:content) { is_expected.not_to match %r{^$crypt_tokens = true;} }
      its(:content) { is_expected.not_to match %r{^$token_lifetime = "3600";} }
      its(:content) { is_expected.not_to match %r{^$mail_from = "admin@#{ssp_domain}";} }
      its(:content) { is_expected.not_to match %r{^$mail_from_name = "Self Service Password";} }
      its(:content) { is_expected.not_to match %r{^$mail_signature = "";} }
      its(:content) { is_expected.not_to match %r{^$notify_on_change = false;} }
      its(:content) { is_expected.not_to match %r{^$mail_smtp_host = '127.0.0.1';} }
      its(:content) { is_expected.not_to match %r{^$mail_smtp_port = 25;} }
      its(:content) { is_expected.not_to match %r{^$mail_smtp_auth = false;} }
    end
  end
end
