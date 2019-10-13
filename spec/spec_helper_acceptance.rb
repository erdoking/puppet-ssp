require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    # we need :
    # * an apache webserver with php
    # * a dedicated system account
    # * an ldap server

    hosts_as('ssp').each do |ssp|
      install_module_on(ssp)
      install_module_dependencies_on(ssp)

      on ssp, puppet('module install puppetlabs-accounts')
      on ssp, puppet('module install puppetlabs-apache')

      pp_ssp = <<-EOS
      $myfqdn = 'localhost'
      $var_dir = '/var/ssp'
      $ssp_root = "${var_dir}/ssp_v1.3"
      $sysuser = 'ssp'
      accounts::user { $sysuser :}

      package { ['php-mbstring', 'php-ldap', 'php-xml']:
        ensure => present,
      }
      ->
      class { 'apache':
        default_vhost => false,
        mpm_module    => 'itk',
        default_mods  => ['php'],
      }

      file { $var_dir :
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755',
      }
      -> apache::vhost { $myfqdn :
        servername => $myfqdn,
        ip => '127.0.0.1',
        port => 80,
        docroot => $ssp_root,
        docroot_owner => $sysuser,
        docroot_group => $sysuser,
        docroot_mode => '0750',
        itk => {
          user => $sysuser,
          group => $sysuser,
        },
        directories => {
          path           => $ssp_root,
          allow_override => 'All'
        },
        require => Accounts::User[$sysuser],
      }
      ->
      file_line { 'ldap.conf TLS_REQCERT never':
        ensure => present,
        path   => '/etc/ldap/ldap.conf',
        line   => 'TLS_REQCERT     never',
      }
      EOS

      apply_manifest_on(ssp, pp_ssp, catch_failures: true)
    end

    hosts_as('ipa').each do |ipa|
      on ipa, puppet('module install stahnma-epel')
      on ipa, puppet('module install adullact-freeipa')

      pp_install_ipa = %(

      $managerpwd = 's3cretlong'
      $bindssp_ldif = '
dn: uid=bindssp,cn=sysaccounts,cn=etc,dc=example,dc=com
add:objectclass:account
add:objectclass:simplesecurityobject
add:uid:bindssp
add:userPassword:bindpw
add:nsIdleTimeout:0
'

      class { 'freeipa':
        ipa_role                    => 'master',
        domain                      => $facts['networking']['domain'],
        ipa_server_fqdn             => $facts['networking']['fqdn'],
        puppet_admin_password       => $managerpwd,
        directory_services_password => $managerpwd,
        install_ipa_server          => true,
        ip_address                  => $facts['networking']['ip'],
        enable_ip_address           => true,
        enable_hostname             => true,
        enable_manage_admins        => false,
        manage_host_entry           => false,
        install_epel                => true,
        ipa_master_fqdn             => $facts['networking']['fqdn'],
        configure_dns_server        => false, # dns are managed somewhere else.
      }
      -> file { '/tmp/bindssp.ldif':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0600',
        content => $bindssp_ldif,
      }

      exec { "/usr/bin/echo '$managerpwd' | /usr/bin/kinit admin":
        subscribe   => File['/tmp/bindssp.ldif'],
        refreshonly => true,
      }
      -> exec { '/usr/bin/ipa pwpolicy-mod --minlife=0 --minlength=1':
      }
      -> exec { '/usr/sbin/ipa-ldap-updater /tmp/bindssp.ldif':
      }
      -> exec { '/usr/bin/echo oldsecret | /usr/bin/ipa user-add jsmith --first=John --last=Smith --password':
      }
      )

      apply_manifest_on(ipa, pp_install_ipa, catch_failures: true)
    end
  end
end
