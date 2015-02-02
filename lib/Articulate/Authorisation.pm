package Articulate::Authorisation;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Component';

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


=cut

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
      return $p;
    }
    elsif ( $p->denied ) {
      return $p;
    }
  }
  return ( $p->deny('No rule granted this permission') );
}


1;
