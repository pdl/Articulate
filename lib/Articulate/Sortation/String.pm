package Articulate::Sortation::String;

use Moo;
with 'Articulate::Role::Sortation::AllYouNeedIsCmp';

sub cmp {
  my $self = shift;
  return ( $_[0] cmp $_[1] );
}

1;
