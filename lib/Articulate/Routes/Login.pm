package Articulate::Routes::Login;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Routes';
use Articulate::Syntax::Routes;
use Articulate::Service;

post '/login' => sub {
  my ($service, $request) = @_;
  my $user_id  = param('user_id');
  my $password = param('password');
  my $redirect = param('redirect') // '/';
  $service->process_request(
    login => {
      user_id  => $user_id,
      password => $password
    }
  )->serialise;
};

post '/logout' => sub {
  my ($service, $request) = @_;
  my $redirect = param('redirect') // '/';
  $service->process_request(
    logout => {}
  )->serialise;
};
