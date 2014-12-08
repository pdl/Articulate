package Articulate::Authorisation;

use Moo;
use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

register authorisation => sub {
  __PACKAGE__->new(plugin_setting);
};

has rules =>
  is      => 'rw',
  default => sub { [] };

sub permitted {
  my $self       = shift;
  my $user_id    = shift;
  my $permission = shift;
  my $location   = shift;
  foreach my $rule_class ( @{ $self->rules } ) {
    Module::Load::load $rule_class;
    my $rule = $rule_class->new;
    my $authed_role;
    if (
      defined ($authed_role = $rule->permitted( $user_id, $permission, $location ) )
    ) {
      session user_id => $user_id;
      return ($authed_role);
    }
  }
  return (undef);
}

register_plugin();

1;
