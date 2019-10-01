require 'spec_helper_acceptance'

ipa_ip = fact_on('ipa', 'networking.ip')

describe 'ssp class' do
  context 'with minimal parameters' do
    hosts_as('ssp').each do |ssp|
      it 'applies idempotently' do
        pp = %(
          class { 'ssp' :
            system_owner      => 'ssp',
            ldap_binddn       => 'uid=bindssp,cn=sysaccounts,cn=etc,dc=example,dc=com',
            ldap_bindpw       => 'bindpw',
            ldap_base         => 'cn=users,cn=accounts,dc=example,dc=com',
            ldap_whochange_pw => 'admin',
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
    end
#
#    hosts_as('ipa').each do |ipa|
#      it 'uses newsecret' do
#        pp = <<-EOS
#          exec { 'kinit jsmith newsecret':
#            path     => '/bin/',
#            command  => 'echo newsecret | kinit jsmith',
#          }
#        EOS
#
#        apply_manifest_on(ipa, pp, catch_failures: true)
#      end
#    end
  end
end
