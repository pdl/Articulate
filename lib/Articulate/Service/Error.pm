package Articulate::Service::Error;

use strict;
use warnings;

=head1 NAME

Articulate::Service::Error - provide an error verb to generate an error

=head1 DESCRIPTION

Given request data like:

  {
    error_type => 'Forbidden',
    error => {}
  }

Creates an error with those attributes and throws it. No access control
is performed.

Useful for when you want to throw an error into a response object from
your route and serialise it, as if the error had genuinely come from a
service.

=cut

use Articulate::Syntax;

use Moo;
with 'Articulate::Role::Service';

sub handle_error {
  my $self       = shift;
  my $request    = shift;
  my $error_type = $request->data->error_type // 'Internal';
  my $error_data = $request->data->error // {};
  throw_error $error_type, $error_data;
}

1;
