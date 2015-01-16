package Articulate::Role::Sortation::AllYouNeedIsCmp;
use strict;
use warnings;
use Moo::Role;

sub order {
  my $self = shift;
  return ( $self->options->{order} // 'asc' ) if $self->can('options');
  return 'asc';
}

sub sort {
  my $self  = shift;
  my $items = shift;
  my $dec = sub {
    my $orig = shift;
    $self->can('decorate')
    ? $self->decorate($orig)
    : $orig
  };
  return [ sort { $self->cmp( $dec->($b), $dec->($a) ) } @$items ] if 'desc' eq $self->order;
  return [ sort { $self->cmp( $dec->($a), $dec->($b) ) } @$items ];
}

sub schwartz {
  my $self  = shift;
  my $items = shift;
  if ( $self->can('decorate') ) {
    return [
      map  { $_->[0] }
      sort { $self->cmp( $a->[1], $b->[1] ) }
      map  { [$_, $self->decorate($_)] }
      @$items
    ];
  }
  else {
    return $self->sort($items);
  }
}

1;
