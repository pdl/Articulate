package Articulate::Role::Service;
use strict;
use warnings;
use Moo::Role;

# The following provide plugins which should be singletons within an application
use Articulate::Storage          ();
use Articulate::Authentication   ();
use Articulate::Authorisation    ();
use Articulate::Enrichment       ();
use Articulate::Interpreter      ();
use Articulate::Augmentation     ();
use Articulate::Validation       ();
use Articulate::Construction     ();
use Articulate::FrameworkAdapter ();

has storage => (
  is      => 'rw',
  default => sub {
    Articulate::Storage::storage;
  }
);

has authentication => (
  is      => 'rw',
  default => sub {
    Articulate::Authentication::authentication;
  }
);

has authorisation => (
  is      => 'rw',
  default => sub {
    Articulate::Authorisation::authorisation;
  }
);

has construction => (
  is      => 'rw',
  default => sub {
    Articulate::Construction::construction;
  }
);

has interpreter => (
  is      => 'rw',
  default => sub {
    Articulate::Interpreter::interpreter;
  }
);

has augmentation => (
  is      => 'rw',
  default => sub {
    Articulate::Augmentation::augmentation;
  }
);

has enrichment => (
  is      => 'rw',
  default => sub {
    Articulate::Enrichment::enrichment;
  }
);

has framework => (
  is      => 'rw',
  default => sub {
    Articulate::FrameworkAdapter::framework;
  }
);

has validation => (
  is      => 'rw',
  default => sub {
    Articulate::Validation::validation;
  }
);

1;
