use Test::More;
use strict;
use warnings;

use_ok $_ for qw(
  Articulate
  Articulate::Authentication
  Articulate::Service
  Articulate::Error::Forbidden
  Articulate::Error::Unauthorised
  Articulate::Error::BadRequest
  Articulate::Error::NotFound
  Articulate::Error::Internal
  Articulate::Item
  Articulate::Validation
  Articulate::Authorisation
  Articulate::Storage
  Articulate::Location
  Articulate::TestEnv
  Articulate::Serialisation
  Articulate::Validation::NoScript
  Articulate::Authentication::Internal
  Articulate::Role::Service
  Articulate::Role::Routes
  Articulate::Routes::Transparent
  Articulate::Serialisation::TemplateToolkit
  Articulate::Serialisation::StatusSetter
  Articulate::Interpreter
  Articulate::Storage::Common
  Articulate::Storage::Local
  Articulate::Service::Simple
  Articulate::Error
  Articulate::Response
  Articulate::Request
  Articulate::Augmentation
  Articulate::Authorisation::OwnerOverride
  Articulate::Authorisation::AlwaysAllow
  Articulate::Interpreter::Markdown
);

done_testing;
