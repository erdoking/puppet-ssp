# ssp

This module install and configure Self Service Password. A web interface to change and reset password in an LDAP directory http://ltb-project.org

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with ssp](#setup)
    * [What ssp affects](#what-ssp-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ssp](#beginning-with-ssp)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Self Service Password permits users to change their password and SSH public key in an LDAP directory.

## Setup

### What ssp affects

Excepted git, the module does not affect your system. It just download SSP and configure it.

### Setup Requirements

The `system_owner` that own the file of Self Service Password must already exists. The module does not create it.

You have to setup a webserver with PHP. Because we do not want to make choise for you about your architecture.

So you can use apache or nginx, simple PHP or php-FMP.

## Usage

The following code :
 * download the default version of SSP to the default path.
 * inodes are owned by already existing system account `ssp`.
 * configure some settings.

```
  class { 'ssp' :
    system_owner      => 'ssp',
    ldap_binddn       => 'uid=bindssp,cn=sysaccounts,cn=etc,dc=example,dc=com',
    ldap_bindpw       => 'bindpw',
    ldap_base         => 'cn=users,cn=accounts,dc=example,dc=com',
    ldap_whochange_pw => 'manager',
    mail_from         => 'admin@example.com',
    manage_git        => true,
    ldap_url          => ['ldap://10.10.10.10'],
  }
```


## Reference

Details in [REFERENCE.md](https://gitlab.adullact.net/adullact/puppet-ssp/blob/master/REFERENCE.md).

## Limitations

This module does not handle usage of questions and SMS.

## Development

Home at URL https://gitlab.adullact.net/adullact/puppet-ssp

Issues and MR are welcome. [CONTRIBUTING.md](https://gitlab.adullact.net/adullact/puppet-ssp/blob/master/CONTRIBUTING.md) gives some guidance about contributing process. If you follow these contributing guidelines your patch will likely make it into a release a little more quickly.

## Release Notes/Contributors/Etc.

Details in [CHANGELOG.md](https://gitlab.adullact.net/adullact/puppet-ssp/blob/master/CHANGELOG.md).


```
Copyright (C) 2018 Association des Développeurs et Utilisateurs de Logiciels Libres
                     pour les Administrations et Colléctivités Territoriales.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/agpl.html>.

```
