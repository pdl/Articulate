package Articulate::TestEnv;

use FindBin;
use Dancer qw(:syntax !after !before);
set appdir      => $FindBin::Bin.'/';
set envdir      => $FindBin::Bin.'/environments';
set public      => $FindBin::Bin.'/public';
set views       => $FindBin::Bin.'/views';
set environment => 'testing';

Dancer::Config->load; #::load_settings_from_yaml($FindBin::Bin.'/config.yml');

use Dancer::Plugin::Articulate;

my $app = articulate_app;

$app->enable;

$app->components->{'storage'}->empty_all_content;

1;
