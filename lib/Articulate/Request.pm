package Articulate::Request;

use Moo;
use Dancer::Plugin;
use Articulate::Service;

register articulate_request => sub {
  __PACKAGE__->new( {
     verb => shift,
     data => shift
  } );
};

has verb =>
  is      => 'rw',
  default => sub { 'error' };

has data =>
  is      => 'rw',
  default => sub { { } };

sub perform {
  service->process_request(shift);
}

register_plugin();

1;
