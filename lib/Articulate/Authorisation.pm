package Articulate::Authorisation;

use Moo;
with 'MooX::Singleton';
use Dancer qw(:syntax !after !before);
use Dancer::Plugin;
use Module::Load ();

=head1 NAME

Articulate::Authorisation

=cut

=head1 CONFIGURATION

  plugins:
    Articulate::Authorisation:
      rules:
      - Articulate::Authorisation::OwnerOverride
      - Articulate::Authorisation::AlwaysAllow

=head1 FUNCTION

=head3 authorisation

Returns a new instance of this object.

B<Warning: In the future this might return a singleton.>

=cut

register authorisation => sub {
  __PACKAGE__->instance(plugin_setting);
};

has rules =>
  is      => 'rw',
  default => sub { [] };

=head3 permitted

  $self->permitted( $user_id, $permission, $location );

Asks each of the rules in turn whether the user has the specified permission for that location.

If so, returns the role under which they have that permission. Otherwise, returns undef. (Each provider should do likewise)

=cut

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
