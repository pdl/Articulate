package Articulate::Role::Service;
use strict;
use warnings;
use Moo::Role;

# The following provide plugins which should be singletons within an application
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
with 'Articulate::Role::Component';

1;
