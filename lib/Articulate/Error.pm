package Articulate::Error;

use Dancer::Plugin;
use Module::Load;
use overload '""' => sub { shift->simple_message };

register throw_error => sub {
  my ( $type, $message ) = @_;
  my $class   = __PACKAGE__ . ( $type ? '::' . $type : '' );
  $class->throw( { ( $message ? ( simple_message => $message) : () ) } );
};

use Moo;
with 'Throwable';

has simple_message =>
  is      => 'rw',
  default => 'An unknown error has occurred';

has http_code =>
  is      => 'rw',
  default => 500,
  coerce  => sub { 0+shift };

has caller =>
  is      => 'rw',
  default => sub{ ( [caller(0)]->[0] =~ m/Throwable/) ? ['hmm',caller(2)] : [caller(1)] };

register_plugin();

# This needs to go at the end, because of Class::XSAccessor stuff

Module::Load::load (__PACKAGE__.'::'.$_) for qw(
  BadRequest
  Forbidden
  Internal
  NotFound
  Unauthorised
);

1;
