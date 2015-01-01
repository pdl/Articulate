use Test::More;
use strict;
use warnings;
use Articulate::Authorisation::AlwaysAllow;
use Articulate::Permission;

my $rule = Articulate::Authorisation::AlwaysAllow->instance;

my $result = $rule->permitted(permission 'anybody', read => 'data' );
isa_ok ($result, 'Articulate::Permission');
ok ($result, 'Result should be true');
ok ($result->granted, 'Result should be that permission was granted'); # this is probably overkill

done_testing ();
