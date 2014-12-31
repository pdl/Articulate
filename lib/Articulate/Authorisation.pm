package Articulate::Authorisation;

use Moo;
with 'MooX::Singleton';
use Dancer qw(:syntax !after !before);
use Dancer::Plugin;
use Module::Load ();
use Articulate::Syntax qw(instantiate_array);
use Articulate::Permission;

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
  default => sub { [] },
  coerce  => sub { instantiate_array(@_) };

=head3 permitted

  $self->permitted( $user_id, $permission, $location );

Asks each of the rules in turn whether the user has the specified permission for that location.

If so, returns the role under which they have that permission. Otherwise, returns undef. (Each provider should do likewise)

=cut

sub permitted {
  my $self       = shift;
  my $user_id    = shift;
  my $verb       = shift;
  my $location   = shift;
  my $p = permission ($user_id, $verb, $location);
  foreach my $rule ( @{ $self->rules } ) {
    my $authed_role;
    if (
      $rule->permitted( $p )
    ) {
      session user_id => $user_id;
      return ($p);
    }
    elsif ( $p->denied ) {
      return $p;
    }
  }
  return ($p->deny);
}

register_plugin();

1;
