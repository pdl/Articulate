package Articulate::Routes::Login;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Routes';
use Articulate::Syntax::Routes;
use Articulate::Service;

post '/login' => sub {
  my ($service, $request) = @_;
  my $user_id  = $request->params->{'user_id'};
  my $password = $request->params->{'password'};
  my $redirect = $request->params->{'redirect'} // '/';
  $service->process_request(
    login => {
      user_id  => $user_id,
      password => $password
    }
  )->serialise;
};

post '/logout' => sub {
  my ($service, $request) = @_;
  my $redirect = $request->params->{'redirect'} // '/';
  $service->process_request(
    logout => {}
  )->serialise;
};
