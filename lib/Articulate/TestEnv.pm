package Articulate::TestEnv;

use FindBin;
use Dancer qw(:syntax !after !before);
set appdir      => $FindBin::Bin.'/';
set envdir      => $FindBin::Bin.'/environments';
set public      => $FindBin::Bin.'/public';
set views       => $FindBin::Bin.'/views';
set environment => 'testing';
#set require_environment => 'testing';

Dancer::Config->load; #::load_settings_from_yaml($FindBin::Bin.'/config.yml');

use Articulate;

articulate_app->enable;

#use Articulate::Storage;
articulate_app->components->{'storage'}->empty_all_content;

#use YAML;

1;
