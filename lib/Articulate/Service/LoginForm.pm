package Articulate::Service::LoginForm;

use strict;
use warnings;

use Articulate::Syntax;

# The following provide objects which must be created on a per-request basis
use Articulate::Request;
use Articulate::Response;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

sub handle_login_form {
  my $self     = shift;
  my $request  = shift;
  return response 'form/login', {
    form => { },
  };
}

1;
