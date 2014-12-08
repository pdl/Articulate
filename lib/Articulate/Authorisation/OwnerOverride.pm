package Articulate::Authorisation::OwnerOverride;

use Moo;

sub permitted {
  my $self       = shift;
  my $user_id    = shift // '';
  return ( $user_id eq 'owner' ? $user_id : undef );
}

1;