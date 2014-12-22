package Articulate::Response;

use Moo;
use Dancer::Plugin;
use Articulate::Serialisation ();


=head1 NAME

Articulate::Response - represent a response

=cut

=head1 FUNCTIONS

=head3 response
=head3 articulate_response

  my $response = response type => $data;

Creates a new response, using the type and data supplied as the respective arguments. Using this constructor, the error code will be 200 unless C<type> is C<error>.

=cut

register response => sub {
  __PACKAGE__->new( {
    type => $_[0],
    data => $_[1],
    http_code => ($_[0] eq 'error' ? 500 : 200),
  } );
};

=head1 METHODS

=head3 new

An unremarkable Moo constructor.

=cut

=head3 serialise

Sends the response to Articulate::Serialisation->serialise.

Note: the behaviour of this method may change!

=cut

sub serialise { # this is convenient as it is probably the next thing which will always be done.
  Articulate::Serialisation::serialisation->serialise (shift);
}


=head1 ATTRIBUTES

=head3 http_code

The HTTP response code which best applies to the response. The default is 500.

It is not guaranteed that this will be passed to the ultimate client (e.g. a later error may cause a 500; the service may be accessed in a way other than HTTP).

=cut

has http_code =>
  is      => 'rw',
  default => 500,
  coerce  => sub { 0+shift };


=head3 type

The type of response, which will be used by serialisers etc. to determine how to complete processing (e.g. which template to use).

=cut

has type =>
  is      => 'rw',
  default => sub { 'error' };

=head3 data

The actual content of the response, including any metadata. Typically this will be of the form

  {
    item => {
      article => {
        meta    => { ... }
        content => " ... "
      }
    }
  }

=cut

has data =>
  is      => 'rw',
  default => sub { { } };

register_plugin();

1;
