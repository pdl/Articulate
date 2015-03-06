use Test::More;
use strict;
use warnings;

use Articulate::TestEnv;
use Articulate::Service;
use Articulate::Syntax;
use FindBin;

my $app = app_from_config();

my $service = $app->components->{'service'};
my $verbs   = $service->enumerate_verbs;

is( ref $verbs, ref [] );

ok( grep { $_ eq 'create' } @$verbs );

foreach my $args (
  [ create => { location => 'zone/public/article/hello-world' } ],
  [
    new_request( create => { location => 'zone/public/article/hello-world', } )
  ],
  )
{
  my $why = (
    ( ref $args->[0] eq ref [] )
    ? 'Process request with raw arguments'
    : 'Process Articulate::Request object'
  );
  subtest $why => sub {
    my $response = $service->process_request(@$args);
    is( ref $response,
      'Articulate::Response', 'Service should always return a response' );
    isnt( $response->http_code, 404, 'The correct service was found' );
  };
}

subtest 'Made-up verb' => sub {
  my $response = $service->process_request('frob');
  is( ref $response,
    'Articulate::Response', 'Service should always return a response' );
  is( $response->http_code, 404, 'No service was found' );
};

done_testing;
