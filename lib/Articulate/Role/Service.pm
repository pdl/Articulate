package Articulate::Role::Service;
use strict;
use warnings;
use Moo::Role;

# The following provide plugins which should be singletons within an application
use Articulate::Storage          ();
use Articulate::Authentication   ();
use Articulate::Authorisation    ();
use Articulate::Enrichment       ();
use Articulate::Augmentation     ();
use Articulate::Validation       ();
use Articulate::Construction     ();
use Articulate::FrameworkAdapter ();

use Class::Inspector;

has verbs => (
  is      => 'rw',
  default => sub {
    my $self = shift;
    return {
      map { m/^(handle_(.*))$/; $2 => $1; }
      grep { /^handle_/ }
      @{ Class::Inspector->methods(ref $self) },
    };
  },
  coerce  => sub {
    my $original = shift;
    if ( ref $original eq ref {} ) {
      return $original;
    }
    elsif ( ref $original eq ref {} ) {
      return { map { $_ => "handle_$_"; } @$original };
    }
    return { $original => "handle_$original" }
  },
);

sub process_request {
  my $self    = shift;
  my $request = shift;
  my $verbs   = $self->verbs;
  my $verb    = $request->verb;
  if ( exists $verbs->{ $verb } ) {
    my $method = $verbs->{ $verb };
    return $self->$method($request, @_);
  }
  return undef; # whatever else the user wants, we can't provide it
}

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
