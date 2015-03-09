use Test::More;
use strict;
use warnings;
use Articulate::Authentication::Preconfigured;
use Articulate::Credentials qw( new_credentials );

my $provider =
  Articulate::Authentication::Preconfigured->new(
  passwords => { alice => 'secret', bob => 'insecure' } );

my $result = $provider->authenticate( new_credentials 'alice', 'secret' );
isa_ok( $result, 'Articulate::Credentials' );
ok( $result,           'Result should be true' );
ok( $result->accepted, 'Result should be that credentials were accepted' );

$result = $provider->authenticate( new_credentials 'bob', 'insecure' );
isa_ok( $result, 'Articulate::Credentials' );
ok( $result,           'Result should be true' );
ok( $result->accepted, 'Result should be that credentials were accepted' );

$result = $provider->authenticate( new_credentials 'alice', 'guess' );
isa_ok( $result, 'Articulate::Credentials' );
ok( !$result,           'Result should be false' );
ok( !$result->rejected, 'Result should not be that credentials were rejected' );

$result = $provider->authenticate( new_credentials 'root', 'guess' );
isa_ok( $result, 'Articulate::Credentials' );
ok( !$result,           'Result should be false' );
ok( !$result->rejected, 'Result should not be that credentials were rejected' );

$result = $provider->authenticate( new_credentials 'alice' );
isa_ok( $result, 'Articulate::Credentials' );
ok( !$result,           'Result should be false' );
ok( !$result->rejected, 'Result should not be that credentials were rejected' );

$result = $provider->authenticate( new_credentials undef, 'password' );
isa_ok( $result, 'Articulate::Credentials' );
ok( !$result,           'Result should be false' );
ok( !$result->rejected, 'Result should not be that credentials were rejected' );

done_testing();
