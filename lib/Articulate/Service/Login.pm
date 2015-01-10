package Articulate::Service::Login;

use strict;
use warnings;

use Dancer qw(:syntax !after !before); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use Dancer::Plugin;


use Articulate::Service;

# The following provide objects which must be created on a per-request basis
# use Articulate::Location;
# use Articulate::Item;
# use Articulate::Error;
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
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(login logout);
  return undef; # whatever else the user wants, we can't provide it
}

sub _login {
  my $self     = shift;
  my $request  = shift;

  my $user_id  = $request->data->{user_id};
  my $password = $request->data->{password};

  if ( defined $user_id ) {
    if ( $self->authentication->login ($user_id, $password) ) {
      $self->framework->user( $user_id );
      response success => { user => $user_id };
    } # Can we handle all the exceptions with 403s?
    else {
      throw_error Forbidden => 'Incorrect credentials';
    }
  }
  else {
    # todo: see if we have email and try to identify a user and verify with that
    throw_error Forbidden => 'Missing user id';
  }

}

sub _logout {
  my $self     = shift;
  my $request  = shift;
  my $user_id  = $self->framework->user;
  session->destroy();
  response success => { user_id => $user_id };
}


1;
