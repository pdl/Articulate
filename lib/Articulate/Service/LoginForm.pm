package Articulate::Service::LoginForm;

use strict;
use warnings;

use Dancer::Plugin;
use Articulate::Syntax;

# The following provide objects which must be created on a per-request basis
use Articulate::Request;
use Articulate::Response;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

use Moo;

sub process_request {
  my $self    = shift;
  my $request = shift;
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(login_form);
  return undef; # whatever else the user wants, we can't provide it
}

sub _login_form {
  my $self     = shift;
  my $request  = shift;
  return response 'form/login', {
    form => { },
  };
}

1;
