package Articulate::Authorisation::AlwaysAllow;

use Moo;
with 'MooX::Singleton';

sub permitted {
  my $self = shift;
  return 1;
}

1;
