package Articulate::Response;

use Moo;
use Dancer::Plugin;
use Articulate::Serialisation ();

register response => sub {
  __PACKAGE__->new( {
    type => $_[0],
    data => $_[1],
    http_code => ($_[0] eq 'error' ? 500 : 200),
  } );
};

has http_code =>
  is      => 'rw',
  default => 500,
  coerce  => sub { 0+shift };

has type =>
  is      => 'rw',
  default => sub { 'error' };

has data =>
  is      => 'rw',
  default => sub { { } };

sub serialise { # this is convenient as it is probably the next thing which will always be done.
  Articulate::Serialisation::serialisation->serialise (shift);
}

register_plugin();

1;
