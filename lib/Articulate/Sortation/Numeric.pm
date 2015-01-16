package Articulate::Sortation::Numeric;

use Moo;
with 'Articulate::Role::Sortation::AllYouNeedIsCmp';

sub cmp {
  my $self = shift;
  return shift <=> shift;
}

1;
