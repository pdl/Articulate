package Articulate::Role::Routes;
use strict;
use warnings;
use Moo::Role;
use Articulate::Service;

sub enable { #ideally we want this to be able to switch on and off the routes.
  my $self = shift;
  my $class = ref $self;
  my $routes = "${class}::__routes";
  {
    no strict 'refs';
    $$routes //= [];
    $_->(articulate_service) for @$$routes;
  }
  $self->enabled(1);
}

has enabled => (
  is      => 'rw',
  default => sub { 0 },
);

1;
