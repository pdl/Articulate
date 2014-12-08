package Articulate::Authorisation::AlwaysAllow;

use Moo;

sub permitted {
  my $self = shift;
  return 1;
}

1;
