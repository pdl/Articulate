package Articulate::Sortation::MetaDelver;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Sortation::AllYouNeedIsCmp';

use Articulate::Syntax qw(instantiate dpath_get);
use Dancer::Plugin;

=head1 NAME

Articulate::Sortation::MetaDelver - delve into the metadata and sort it

=head1 METHODS

=head3 sort

=cut

has options => (
  is      => 'rw',
  default => sub { {} },
  coerce  => sub {
    my $orig         = shift;
    $orig->{cmp}   //= 'Articulate::Sortation::String';
    $orig->{cmp}     = instantiate ( $orig->{cmp} );
    $orig->{field} //= '/';
    $orig->{field}   =~ s~^([^/].*)$~/$1~;
    $orig->{order} //= 'asc';
    return $orig;
  },
);


sub decorate {
  my $self = shift;
  my $item = shift;
  return ( dpath_get( $item->meta, $self->options->{field} ) // '' )
}

sub cmp {
  my $self  = shift;
  my $left  = shift;
  my $right = shift;
  $self->options->{cmp}->cmp( $left, $right )
}


1;
