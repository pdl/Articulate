#!/usr/bin/env perl
use Dancer;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use lib ("$FindBin::Bin/../../../lib");
use Articulate;
my $app = articulate_app;
$app->enable;
dance;
