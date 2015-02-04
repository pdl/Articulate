package Dancer::Plugin::Articulate;

use Dancer::Plugin;
use Articulate;

=head1 NAME

Dancer::Plugin::Articulate - use Articulate in your Dancer App

=head1 SYNOPSIS

	use Dancer;
	use Dancer::Plugin::Articulate;
	my $app = articulate_app;
	$app->enable;
	dance;

	# in config.yml
	plugins:
		Articulate:
			framework: Articulate::FrameworkAdapter::Dancer1
			# Other Articulate config goes here

Creates an instance of L<Articulate> using your Dancer config, and enables the app, declaring routes, etc.
See L<Articulate> for how to configure and use it, and L<Articulate::FrameworkAdapter::Dancer1> for details of the integration between Dancer1 and Articulate.

=head1 SEE ALSO

=over

=item * L<Dancer2::Plugin::Articulate>

=item * L<Dancer::Plugins>

=item * L<Dancer::Config>

=item * L<Articulate::FrameworkAdapter::Dancer1>

=back

=cut

register articulate_app => sub {
	return Articulate->instance(plugin_setting);
};

register_plugin();

1;
