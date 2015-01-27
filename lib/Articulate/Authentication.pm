package Articulate::Authentication;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';
use Dancer::Plugin;
use Articulate::Syntax qw(instantiate_array);

register authentication => sub {
  __PACKAGE__->instance(plugin_setting);
};

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


register_plugin();

1;
