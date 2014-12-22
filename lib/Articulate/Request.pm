package Articulate::Request;

use Moo;
use Dancer::Plugin;
use Articulate::Service;

=head1 NAME

Articulate::Request - represent a request

=cut

=head1 FUNCTIONS

=head3 articulate_request

  my $request = articulate_request verb => $data;

Creates a new request, using the verb and data supplied as the respective arguments.

=cut

register articulate_request => sub {
  __PACKAGE__->new( {
     verb => shift,
     data => shift
  } );
};

=head1 METHODS

=head3 new

An unremarkable Moo constructor.

=cut

=head3 perform

Sends the to the articulate service.

Note: the behaviour of this method may change!

=cut

sub perform {
  service->process_request(shift);
}

=head1 ATTRIBUTES

=head3 verb

The action being performed, e.g. C<create>, C<read>, etc. The verbs available are entirely dependant on the application: A request will be handled by a service provider (see Articulate::Service) which will typically decide if it can fulfil the request based on the verb.

=cut

has verb =>
  is      => 'rw',
  default => sub { 'error' };

=head3 data

The information passed along with the request, e.g. C<< { location => '/zone/public/article/hello-world' } >>. This should always be a hashref.

=cut

has data =>
  is      => 'rw',
  default => sub { { } };

register_plugin();

1;
