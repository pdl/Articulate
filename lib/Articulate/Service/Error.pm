package Articulate::Service::Error;

use strict;
use warnings;

use Dancer qw(:syntax !after !before); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use Dancer::Plugin;

use Articulate::Construction;

use Articulate::Request;
use Articulate::Response;
use Articulate::Syntax;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

use Try::Tiny;
use Scalar::Util qw(blessed);

use Moo;

sub process_request {
  my $self    = shift;
  my $request = shift;
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(error);
  return undef; # whatever else the user wants, we can't provide it
}

sub _error {
  my $self     = shift;
  my $request  = shift;
  my $error_type = $request->error_type // 'Internal';
  my $error_data = $request->error // {};
  throw_error $error_type, $error_data;
}
