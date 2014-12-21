package Articulate::Response;

use Moo;
use Dancer::Plugin;

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

register_plugin();

1;
