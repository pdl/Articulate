use Test::More skip_all => 'Not part of the core';
use strict;
use warnings;

# the order is important
use Articulate;
use Dancer::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 200, 'response status is 200 for /';

done_testing;
