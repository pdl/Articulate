#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use lib ("$FindBin::Bin/../../../lib");

{
  package PlainSpeaking;
  use Moo;
  use Dancer2;
  use Dancer2::Plugin::Articulate;
  my $aa = articulate_app;
  $aa->enable;
  #use Data::Dumper; $Data::Dumper::Maxdepth=5; die Dumper $aa->routes;
  dance;
}
use Dancer2 appname => 'PlainSpeaking';
my $app = PlainSpeaking->to_app;

#use Articulate;
#Articulate->instance(Dancer2::runner->app->config->{plugin}->{Articulate})->enable;
