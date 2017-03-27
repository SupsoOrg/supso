# Helpful things to remember when developing

## Publishing to Rubygems

Ensure the version number is updated (lib/supso/version.rb.

rspec

gem build supso.gemspec

Make sure your ~/.gem credentials are the correct one

gem push supso-VERSION.gem

## Requiring the local version of the Gem

Use something like this:

gem 'supso', '0.9.0', path: 'local/path/to/gem'

## Philosophy

Super Source is split into two types of packages: the supso command line interface,
and packages included with the projects that use Super Source.

This gem, the Super Source Ruby gem, is an example of the former: the command line interface.

The supso command line interface should never be directly added as a requirement from the projects.
