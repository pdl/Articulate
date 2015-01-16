package Articulate::Sortation::MetaDelver;

use Moo;
with 'Articulate::Role::Sortation::AllYouNeedIsCmp';

use Articulate::Syntax qw(instantiate);
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
    $orig->{field} //= [];
    $orig->{field}   = [ grep { $_ ne '' } split ( qr~/~, $orig->{field} ) ] if !ref $orig->{field};
    $orig->{order} //= 'asc';
    return $orig;
  },
);

sub dive {
  my $self  = shift;
  my $item  = shift;
  my $field = shift;
  my $meta  = $item->meta;
  my $curr  = [$meta];
  foreach my $key ( @$field ) {
    return '' unless exists $curr->[0]->{$key};
    $curr = [ $curr->[0]->{$key} ];
  }
  return $curr->[0];
}

sub decorate {
  my $self = shift;
  my $item = shift;
  return $self->dive( $item, $self->options->{field} )
}

sub cmp {
  my $self  = shift;
  my $left  = shift;
  my $right = shift;
  $self->options->{cmp}->cmp( $left, $right )
}


1;
