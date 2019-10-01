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

Briefly tell users why they might want to use your module. Explain what your module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module is what they want.

## Setup

### What ssp affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For example, folks can probably figure out that your mysql_instance module affects their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* Files, packages, services, or operations that the module will alter, impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements

The `system_owner` that own the file of Self Service Password must already exists. The module does not create it.


### Beginning with ssp

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

Details in [REFERENCE.md](REFERENCE.md).

## Limitations

This module does not handle usage of questions and SMS.

## Development

Home at URL https://gitlab.adullact.net/adullact/puppet-ssp

Issues and MR are welcome. [CONTRIBUTING.md](CONTRIBUTING.md) gives some guidance about contributing process. If you follow these contributing guidelines your patch will likely make it into a release a little more quickly.

## Release Notes/Contributors/Etc.

Details in [CHANGELOG.md](CHANGELOG.md).
