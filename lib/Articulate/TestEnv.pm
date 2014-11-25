package Articulate::TestEnv;

use FindBin;
use Dancer qw(:syntax);
config->{appdir} = $FindBin::Bin.'/..';
set environment => 'testing';

Dancer::Config->load;

#use YAML;

#die Dump config;

1;
