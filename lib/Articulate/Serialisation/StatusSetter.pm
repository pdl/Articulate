package Articulate::Serialisation::StatusSetter;

use Moo;
with 'MooX::Singleton';

use Dancer qw(:syntax); # for status

=head1 NAME

Articulate::Serialisation::StatusSetter - send the right HTTP status response

=head1 METHODS

=head3 serialise

Sets the status of the Dancer response you're going to be sending to match the status of the Articulate Response.

=cut

sub serialise {
  my $self     = shift;
  my $response = shift;
  if ( ref $response and $response->can('http_code') ) {
		status $response->http_code // 500;
	}
  else {
    status $response->http_code // 500;
  }
  return undef; # we want to continue with other serialisations
}

1;
