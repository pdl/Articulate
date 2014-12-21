package Articulate::Serialisation::StatusSetter;

use Moo;
with 'MooX::Singleton';

use Dancer qw(:syntax); # for status

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
