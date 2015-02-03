package Dancer2::Plugin::Articulate;
use strict;
use warnings;

use Dancer2::Plugin;
use Articulate;

register articulate_app => sub {
	my $dsl = shift;
	Articulate->instance (plugin_setting);
}, { is_global => 1};

register_plugin for_versions => [2];

1;
