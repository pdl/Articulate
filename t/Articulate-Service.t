use Test::More;
use strict;
use warnings;
use Articulate::TestEnv;

use Articulate::Service;

my $verbs = articulate_service->enumerate_verbs;

is (ref $verbs, ref []);


done_testing;
