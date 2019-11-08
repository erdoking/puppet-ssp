# @summary Install and configure self-service-password
#
# Install and configure self-service-password
#
# @example
#    class { 'ssp' :
#      system_owner      => 'ssp',
#      ldap_binddn       => 'uid=bindssp,cn=sysaccounts,cn=etc,dc=example,dc=com',
#      ldap_bindpw       => 'bindpw',
#      ldap_base         => 'cn=users,cn=accounts,dc=example,dc=com',
#      ldap_whochange_pw => 'manager',
#      mail_from         => 'admin@example.com',
#      manage_git        => true,
#      ldap_url          => ['ldap://ldap_address'],
#    }
#
# @param system_owner system user account that own files
# @param ldap_binddn DN used to bind directory
# @param ldap_bindpw Password of the DN used to bind directory
# @param ldap_base Base search where users are searched.
# @param ldap_whochange_pw
#   who change the password ?
#     * user: the user itself
#     * manager: the above binddn
# @param ldap_whochange_sshkey
#   who change the SSH key ?
#     * user: the user itself
#     * manager: the above binddn
# @param ldap_filter Filter on reserched objects in LDAP
# @param manage_git Install git if true, required if git is not installed by an other process.
# @param manage_rootpath If true creates the path defined by $system_rootpath
# @param system_rootpath Path where SSP is installed
# @param system_rootpath_mode Unix mode set to path defined by $system_rootpath
# @param version_tag Version of installed SSP
# @param ldap_url List of LDAP URLs
# @param ldap_starttls Use StartTLS instead of LDAP over SSL
# @param ldap_login_attribute LDAP attribute used as login
# @param ldap_fullname_attribute LDAP attribute used as full name
# @param lang Language of SSP webui.
# @param show_menu Display menu on top of SSP webui
# @param show_help Display help messages
# @param logo URN of logo image
# @param background_image URN of background image
# @param login_forbidden_chars Characters considered as invalid in login
# @param obscure_failure_messages
#   Hide some messages to not disclose sensitive information.
#   These messages will be replaced by value of obscure_failure_messages.
# @param default_action Default action displayed by the webui
# @param use_change enable (with true) or disable (with false) standard change form usage.
# @param use_tokens enable (with true) or disable (with false) tokens usage.
# @param crypt_tokens crypt tokens (with true) or no (with false)
# @param token_lifetime When token are used, the token lifetime.
# @param mail_address_use_ldap Mail is got from LDAP.
# @param mail_from Who the email should come from
# @param mail_from_name Name displayed with mail_from
# @param mail_signature Signature added in mail
# @param notify_on_change Notify users anytime their password is changed
# @param mail_sendmailpath Sendmail path see https://github.com/PHPMailer/PHPMailer
# @param mail_smtp_host SMTP host to use
# @param mail_smtp_port SMTP port to use
# @param mail_smtp_auth Enable SMTP auth is true
# @param mail_smtp_user SMTP user used with SMTP auth
# @param mail_smtp_pass SMTP password used with SMTP auth
# @param pwd_min_length Local password policy applied before directory password policy. Minimal length.
# @param pwd_max_length Local password policy applied before directory password policy. Maximum length
# @param pwd_min_lower Local password policy applied before directory password policy. Minimal lower characters
# @param pwd_min_upper Local password policy applied before directory password policy. Minimal upper characters
# @param pwd_min_digit Local password policy applied before directory password policy. Minimal digit characters
# @param pwd_min_special Local password policy applied before directory password policy. Minimal special characters
# @param pwd_no_reuse Local password policy applied before directory password policy. Don't reuse the same password as currently
# @param pwd_special_chars Definition of special characters
# @param pwd_forbidden_chars Definition of forbidden characters in password
# @param pwd_diff_login Check that password is different than login
# @param pwd_complexity Number of different class of character required
# @param pwd_show_policy Show policy constraints message
# @param pwd_show_policy_pos Position of password policy constraints message
# @param pwd_no_special_at_ends Disallow use of the only special character as defined in `$pwd_special_chars` at the beginning and end
# @param allow_change_sshkey If true allow changing of sshPublicKey
# @param change_sshkey_attribute What attribute should be changed by the changesshkey action
# @param notify_on_sshkey_change Notify users anytime their sshPublicKey is changed
#
class ssp (
  String[1] $system_owner,
  String[1] $ldap_binddn,
  String[1] $ldap_bindpw,
  String[1] $ldap_base,
  Enum['user','manager'] $ldap_whochange_pw = 'user',
  String[1] $ldap_filter = '(&(objectClass=person)($ldap_login_attribute={login}))',
  Boolean $manage_git = false,
  Boolean $manage_rootpath = false,
  Stdlib::Absolutepath $system_rootpath = '/var/ssp',
  String $system_rootpath_mode = '0750',
  Pattern['^v\d'] $version_tag = 'v1.3',
  Array[Pattern['^ldap']] $ldap_url = ['ldap://localhost'],
  Boolean $ldap_starttls = true,
  String $ldap_login_attribute = 'uid',
  String $ldap_fullname_attribute = 'cn',
  String $lang = 'en',
  Boolean $show_menu = true,
  Boolean $show_help = true,
  Optional[String[1]] $logo = undef,
  Optional[String[1]] $background_image = undef,
  Optional[String[1]] $login_forbidden_chars = undef,
  Optional[String[1]] $obscure_failure_messages = undef,
  Enum['change','sendtoken'] $default_action = 'change',
  Boolean $use_change = true,
  Boolean $use_tokens = true,
  Boolean $crypt_tokens = true,
  Integer $token_lifetime = 3600,
  Boolean $mail_address_use_ldap = true,
  Pattern['^.+@.+'] $mail_from = "admin@${facts['networking']['domain']}",
  String $mail_from_name = 'Self Service Password',
  String $mail_signature = '',
  Boolean $notify_on_change = false,
  Stdlib::Absolutepath $mail_sendmailpath = '/usr/sbin/sendmail',
  Stdlib::Host $mail_smtp_host = '127.0.0.1',
  Integer $mail_smtp_port = 25,
  Boolean $mail_smtp_auth = false,
  Optional[String[1]] $mail_smtp_user = undef,
  Optional[String[1]] $mail_smtp_pass = undef,
  Integer $pwd_min_length = 0,
  Integer $pwd_max_length = 0,
  Integer $pwd_min_lower = 0,
  Integer $pwd_min_upper = 0,
  Integer $pwd_min_digit = 0,
  Integer $pwd_min_special = 0,
  Optional[String] $pwd_special_chars = undef,
  Optional[String[1]] $pwd_forbidden_chars = undef,
  Boolean $pwd_no_reuse = false,
  Boolean $pwd_diff_login = true,
  Integer $pwd_complexity = 0,
  Enum['always','never','oneerror'] $pwd_show_policy = 'never',
  Enum['above','below'] $pwd_show_policy_pos = 'above',
  Boolean $pwd_no_special_at_ends = false,
  Boolean $allow_change_sshkey = false,
  String $change_sshkey_attribute = 'sshPublicKey',
  Enum['user','manager'] $ldap_whochange_sshkey = 'user',
  Boolean $notify_on_sshkey_change = false,
) {

  $_git_url = 'https://github.com/ltb-project/self-service-password.git'
  $_git_package = 'git'
  $_keynumber = fqdn_rand(50, 'tocken_seed')
  $_keyphrase = "${facts['hostname']}${_keynumber}"
  $_ldap_urls = join($ldap_url, ' ')

  # define the default action to unused one is not possible
  if ! $use_change and $default_action == 'change' {
    fail('$use_change is set to false and $default_action is set to "change"')
  }
  if ! $use_tokens and $default_action == 'sendtoken' {
    fail('$use_tokens is set to false and $default_action is set to "sendtoken"')
  }

  # The two others actions available with SSP are not handled by this Puppet module.
  # They are hard coded to false, and not proposed in Enum data type for $default_action
  $_use_sms = false
  $_use_questions = false

  if $manage_git {
    package { 'git':
      ensure => present,
      name   => $_git_package
    }
  } else {
    # hack to permit a fix reference always present
    # used by require attribute with vcsrepo
    package { 'git':
      ensure => present,
      name   => 'bash',
    }
  }

  if $manage_rootpath {
    file { 'rootpath':
      ensure => directory,
      path   => $system_rootpath,
      mode   => $system_rootpath_mode,
      owner  => $system_owner,
      group  => 0,
    }
  } else {
    # hack to permit a fix reference always present
    # used by require attribute with vcsrepo
    file { 'rootpath':
      ensure => directory,
      path   => '/bin',
    }
  }

  vcsrepo { "${system_rootpath}/ssp_${version_tag}":
    ensure   => present,
    provider => git,
    source   => $_git_url,
    revision => $version_tag,
    owner    => $system_owner,
    group    => $system_owner,
    require  => [
      Package['git'],
      File['rootpath'],
    ],
  }

  file { "${system_rootpath}/ssp_${version_tag}/conf/config.inc.local.php":
    ensure  => file,
    owner   => $system_owner,
    group   => $system_owner,
    mode    => '0640',
    content => epp('ssp/config.inc.local.php.epp', {
      'ldap_urls'     => $_ldap_urls,
      'use_sms'       => $_use_sms,
      'use_questions' => $_use_questions,
      'keyphrase'     => $_keyphrase,
      }),
    require => Vcsrepo["${system_rootpath}/ssp_${version_tag}"],
  }
}
