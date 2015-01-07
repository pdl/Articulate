package Articulate::Construction::LocationBased;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';

use Articulate::Syntax;

use Module::Load ();

has types => (
  is => 'rw',
  default => sub { {} },
);

sub construct {
  my $self = shift;
  my $args = shift;
  my $location = loc ($args->{location});
  if ( scalar ( @$location ) and 0 == (scalar ( @$location ) % 2) ) {
    if ( exists $self->types->{ $location->[-2] } ) {
      my $class = $self->types->{ $location->[-2] };
      Module::Load::load($class);
      return $class->new($args);
    }
  }
  return undef;
}

1;
