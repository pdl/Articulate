package Articulate::Role::Flow;
use strict;
use warnings;
use Moo::Role;

sub enrich {
  my $self = shift;
  $self->process_method( enrich => @_);
}

sub augment {
  my $self = shift;
  $self->process_method( augment => @_);
}

sub _delegate {
  my ( $self, $method, $providers, $args ) = @_;
  foreach my $provider ( @$providers ) {
    my $result = $provider->$method(@$args);
    return $result unless defined $result;
  }
  return $args->[0];
}

1;
