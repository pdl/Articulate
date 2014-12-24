package Articulate::TestEnv;

use FindBin;
use Dancer qw(:syntax !after !before);
config->{appdir} = $FindBin::Bin.'/..';
set environment => 'testing';

Dancer::Config->load;

use Articulate;

articulate_app->enable;

#use YAML;

#die Dump config;

1;
