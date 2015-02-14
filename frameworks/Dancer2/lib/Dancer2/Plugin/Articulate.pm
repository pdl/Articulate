package Dancer2::Plugin::Articulate;
use strict;
use warnings;

use Dancer2::Plugin;
use Articulate;

=head1 NAME

Dancer2::Plugin::Articulate - use Articulate in your Dancer2 App

=head1 SYNOPSIS

	# in config.yml
	plugins:
		Articulate:
			framework:
				Articulate::FrameworkAdapter::Dancer2:
					appname: MyApp
			# Other Articulate config goes here

Creates an instance of L<Articulate> using your Dancer2 config, and enables the app, declaring routes, etc.
See L<Articulate> for how to configure and use it, and L<Articulate::FrameworkAdapter::Dancer2> for details of the integration between Dancer2 and Articulate.

=head1 SEE ALSO

=over

=item * L<Dancer::Plugin::Articulate>

=item * L<Dancer2::Plugins>

=item * L<Dancer2::Config>

=item * L<Articulate::FrameworkAdapter::Dancer2>

=back

=cut

register articulate_app => sub {
	my $dsl = shift;
	Articulate->instance (plugin_setting);
}, { is_global => 1};

register_plugin for_versions => [2];

1;
