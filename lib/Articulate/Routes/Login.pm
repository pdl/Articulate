package Articulate::Routes::Login;

use Moo;
with 'Articulate::Role::Routes';

use Dancer qw(:syntax !after !before);
use Articulate::Service;

my $service = articulate_service;

post '/login' => sub {
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
  my $redirect = param('redirect') // '/';
  $service->process_request(
    logout => {}
  )->serialise;
};
