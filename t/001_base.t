use Test::More;
use strict;
use warnings;

use_ok $_ for qw(
  Articulate
  Articulate::Augmentation
  Articulate::Augmentation::Interpreter
  Articulate::Augmentation::Interpreter::Markdown
  Articulate::Authentication
  Articulate::Authentication::Internal
  Articulate::Authentication::Preconfigured
  Articulate::Authorisation
  Articulate::Authorisation::AlwaysAllow
  Articulate::Authorisation::OwnerOverride
  Articulate::Authorisation::Preconfigured
  Articulate::Construction
  Articulate::Construction::LocationBased
  Articulate::Enrichment
  Articulate::Enrichment::DateCreated
  Articulate::Enrichment::DateUpdated
  Articulate::Error
  Articulate::Error::AlreadyExists
  Articulate::Error::BadRequest
  Articulate::Error::Forbidden
  Articulate::Error::Internal
  Articulate::Error::NotFound
  Articulate::Error::Unauthorised
  Articulate::FrameworkAdapter
  Articulate::Item
  Articulate::Item::Article
  Articulate::Location
  Articulate::LocationSpecification
  Articulate::Navigation
  Articulate::Permission
  Articulate::Request
  Articulate::Response
  Articulate::Role::Routes
  Articulate::Role::Service
  Articulate::Routes::Login
  Articulate::Routes::Transparent
  Articulate::Routes::TransparentForms
  Articulate::Routes::TransparentPreviews
  Articulate::Serialisation
  Articulate::Serialisation::SiteConfig
  Articulate::Serialisation::StatusSetter
  Articulate::Serialisation::TemplateToolkit
  Articulate::Service
  Articulate::Service::Error
  Articulate::Service::List
  Articulate::Service::Login
  Articulate::Service::LoginForm
  Articulate::Service::Simple
  Articulate::Service::SimpleForms
  Articulate::Service::SimplePreviews
  Articulate::Storage
  Articulate::Storage::Common
  Articulate::Storage::Local
  Articulate::Syntax
  Articulate::TestEnv
  Articulate::Validation
  Articulate::Validation::NoScript

);

done_testing;
