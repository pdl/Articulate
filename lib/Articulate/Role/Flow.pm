package Articulate::Role::Flow;
use strict;
use warnings;
use Moo::Role;

=head1 NAME

Articulate::Role::Flow - methods

=head1 DESCRIPTION

This is a helper class for flow roles. All consumers of this role must have a C<process_method> method which can be called as follows:

  $self->process_method( $methodname, $item, $request );

This role provides a method C<_delegate> which can be used to delegate to other providers. It is called as:

  $self->_delegate( $method, $providers, $args )

where C<$providers> and C<$args> are arrayrefs.

=cut

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
