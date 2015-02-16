use strict;
use warnings;
use Test::More;
use Test::Pod::Coverage;
use FindBin;

BEGIN {
  plan skip_all => 'POD Coverage tests are for release candidate testing'
    unless $ENV{RELEASE_TESTING};
}

pod_coverage_ok( $_ ) for all_modules;

done_testing;
