package Articulate::Role::Service;
use strict;
use warnings;
use Moo::Role;

# The following provide plugins which should be singletons within an application
use Articulate::Storage        ();
use Articulate::Authentication ();
use Articulate::Authorisation  ();
use Articulate::Enrichment     ();
use Articulate::Interpreter    ();
use Articulate::Augmentation   ();
use Articulate::Validation     ();

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

has validation => (
  is      => 'rw',
  default => sub {
    Articulate::Validation::validation;
  }
);

1;
