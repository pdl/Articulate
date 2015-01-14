package Articulate::Service::Error;

use strict;
use warnings;

use Dancer::Plugin;

use Articulate::Request;
use Articulate::Response;
use Articulate::Syntax;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

use Try::Tiny;
use Scalar::Util qw(blessed);

use Moo;

sub handle_error {
  my $self     = shift;
  my $request  = shift;
  my $error_type = $request->error_type // 'Internal';
  my $error_data = $request->error // {};
  throw_error $error_type, $error_data;
}

1;
