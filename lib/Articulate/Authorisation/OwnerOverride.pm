package Articulate::Authorisation::OwnerOverride;

use Moo;
with 'MooX::Singleton';

sub permitted {
  my $self       = shift;
  my $permission = shift;
  $permission->grant('Site owner can do anything') if ( ( $permission->user // '' ) eq 'owner' ); 
  return $permission;
}

1;
