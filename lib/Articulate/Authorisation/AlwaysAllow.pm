package Articulate::Authorisation::AlwaysAllow;

use Moo;
with 'MooX::Singleton';

sub permitted {
  my $self       = shift;
  my $permission = shift;
  $permission->grant('Anything is possible!');
}

1;
