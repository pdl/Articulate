package Articulate::Caching::Native;
use strict;
use warnings;

use Moo;
use DateTime;
with 'Articulate::Role::Component';

sub now { DateTime->now . '' }

has cache => (
  is      => 'rw',
  default => sub { {} },
);

has max_keys => (
  is      => 'rw',
  default => sub { {} },
);

=head1 METHODS

=head3 is_cached

  $caching->is_cached( $what, $location )

=cut

sub is_cached {
  my $self     = shift;
  my $what     = shift;
  my $location = shift;
  return undef unless exists $self->cache->{$location};
  return undef unless exists $self->cache->{$location}->{$what};
  return 1;
}

=head3 get_cached

  $caching->get_cached( $what, $location )

=cut

sub get_cached {
  my $self     = shift;
  my $what     = shift;
  my $location = shift;
  return undef unless exists $self->cache->{$location};
  return undef unless exists $self->cache->{$location}->{$what};
  $self->cache->{$location}->{last_retrieved} = now;
  return $self->cache->{$location}->{$what}->{value};
}

=head3 set_cache

  $caching->set_cache( $what, $location, $value )

=cut

sub set_cache {
  my $self     = shift;
  my $what     = shift;
  my $location = shift;
  $self->_prune;
  return $self->cache->{$location}->{$what}->{value};
}

=head3 clear_cache

  $caching->clear_cache( $what, $location )

=cut

sub clear_cache {
  my $self     = shift;
  my $what     = shift;
  my $location = shift;
  return delete $self->cache->{$location}->{$what};
}

=head3 empty_cache

  $caching->empty_cache( $what, $location )

=cut

sub empty_cache {
  my $self = shift;
  delete $self->cache->{$_} for keys %{ $self->cache };
}

sub _prune {
  my $self      = shift;
  my $to_remove = ( keys %{ $self->cache } ) - $self->max_keys;
  if ( $to_remove > 1 ) {
    $to_remove = $to_remove +
      int( $self->max_keys / 4 ); # so we don't have to do this too often
    foreach my $location (
      sort {
        $self->cached->{$a}->{last_retrieved}
          cmp $self->cached->{$b}->{last_retrieved}
      } keys %{ $self->cached }
      )
    {
      delete $self->cached->{$location};
      last unless --$to_remove;
    }
  }
}
1;
