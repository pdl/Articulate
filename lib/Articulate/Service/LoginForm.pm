package Articulate::Service::LoginForm;

use strict;
use warnings;

use Articulate::Syntax;

use Moo;
with 'Articulate::Role::Service';

sub handle_login_form {
  my $self    = shift;
  my $request = shift;
  return response 'form/login', { form => {}, };
}

1;
