package Articulate;
use Dancer::Plugin;
use Articulate::Service;
use Module::Load ();
our $VERSION = '0.001';

use Moo;

register articulate_app => sub {
	__PACKAGE__->new(plugin_setting);
};

sub enable {
	my $self = shift;
	foreach my $route_class (@{ $self->routes }){
		Module::Load::load($route_class);
		$route_class->new()->enable;
	}
	$self->enabled(1);
}

has enabled =>
	is      => 'rw',
	default => sub { 0 };

has routes =>
	is      => 'rw',
	default => sub { [] };

has service =>
	is      => 'rw',
	default => sub { articulate_service };

register_plugin;

1;
