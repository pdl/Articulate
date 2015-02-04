package Articulate::Authentication;
use strict;
use warnings;

use Moo;

with 'Articulate::Role::Component';

use Articulate::Syntax qw(instantiate_array);

has providers =>
  is      => 'rw',
  default => sub { [] },
  coerce  => sub { instantiate_array(@_) };

sub login {
  my $self       = shift;
  my $user_id    = shift;
  my $password   = shift;
  foreach my $provider ( @{ $self->providers } ) {
    if (
      defined ( $provider->authenticate( $user_id, $password ) )
    ) {
      return ($user_id);
    }
  }
  return (undef);
}

sub create_user {
  my $self       = shift;
  my $user_id    = shift;
  my $password   = shift;
  foreach my $provider ( @{ $self->providers } ) {
    if (
      defined ( $provider->create_user( $user_id, $password ) )
    ) {
      return ($user_id);
    }
  }
  return (undef);
}

1;
