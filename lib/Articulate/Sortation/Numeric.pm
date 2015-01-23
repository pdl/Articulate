package Articulate::Sortation::Numeric;

use Moo;
with 'Articulate::Role::Sortation::AllYouNeedIsCmp';

sub cmp {
  my $self = shift;
  return ( $_[0] <=> $_[1] );
}

1;
