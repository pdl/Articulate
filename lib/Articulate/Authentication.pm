package Articulate::Authentication;

use Moo;
use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

register authentication => sub {
  __PACKAGE__->new(plugin_setting);
};

has rules =>
  is      => 'rw',
  default => sub { [] };

sub login {
  my $self       = shift;
  my $user_id    = shift;
  my $password   = shift;
  foreach my $provider_class ( @{ $self->providers } ) {
    Module::Load::load $provider_class;
    my $provider = $provider_class->new;
    if (
      defined ($provider->authenticate( $user_id, $password ) )
    ) {
      return ($user_id);
    }
  }
  return (undef);
}

register_plugin();

1;
