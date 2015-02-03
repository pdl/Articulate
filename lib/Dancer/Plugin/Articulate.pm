package Dancer::Plugin::Articulate;

use Dancer::Plugin;
use Articulate;

register articulate_app => sub {
	return Articulate->instance(plugin_setting);
};

register_plugin();

1;
