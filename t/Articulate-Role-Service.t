use Test::More;
use strict;
use warnings;
use Articulate::Service::Error;

my $provider = Articulate::Service::Error->instance();

is('error',        join ',', keys   %{ $provider->verbs } );
is('handle_error', join ',', values %{ $provider->verbs } );

done_testing ();
