package Articulate::Role::Routes;
use strict;
use warnings;
use Moo::Role;

sub enable { #ideally we want this to be able to switch on and off the routes.
  my $self = shift;
  $self->enabled(1);
}

has enabled => (
  is      => 'rw',
  default => sub { 0 },
);

1;
