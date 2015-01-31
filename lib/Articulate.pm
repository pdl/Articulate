package Articulate;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';

use Dancer::Plugin;
use Articulate::Service;
use Module::Load ();
our $VERSION = '0.001';

=head1 NAME

Articulate - A lightweight Perl CMS Framework

=head1 WARNING

This is very much in alpha. Things will change. Feel free to build things and have fun, but don't hook up anything business-critical just yet!

=head1 SYNOPSIS

	# (in bin/app.pl)
	use Dancer;
	use Articulate;
	articulate_app->enable;
	dance;

Articulate provides a content management service for your web app. It's lightweight, i.e. it places minimal demands on your app while maximising 'whipuptitude': it gives you a single interface in code to a framework that's totally modular underneath, and it won't claim any URL endpoints for itself.

You don't need to redesign your app around Articulate, it's a service that you call on when you need it, and all the 'moving parts' can be switched out if you want to do things your way.

It's written in Perl, the fast, reliable 'glue language' that's perfect for agile web development projects.

=head1 GETTING STARTED

Don't forget to install Articulate - remember, it's a library, not an app.

Check out the examples in the C<examples> folder of the distribution.

To add Articulate to your own app, you'll need to:

=over

=item * add it to your C<bin/app.pl> or similar (see example above)

=item * edit your C<config.yml> to configure the components you want (check each of the components for a description of their config options - or just borrow a config from one of the examples)

=item * write any custom code you want if you don't like what's there, and just swap it out in the config.

=item * polish off your front-end, all the backend is taken care of!

=back

Curious about how it all fits together? Read on...

=head1 DESCRIPTION

Articulate is a set of plugins which work together to create a content management service that will sit alongside an existing Dancer app or form the basis of a new one.

If you want to see one in action, try running:

	cd examples/plain-speaking
	perl bin/app.pl

You can see how it's configured by looking at

	examples/plain-speaking/config.yml

Notice that bin/app.pl doesn't directly load anything but Articulate. Everything you need is in config.yml, and you can replace components with ones you've written if your app needs to do different things.

=head2 Response/Request lifecycle summary

In a B<route>, you parse user input and pick the parameters you want to send to the service. Have a look at L<Articulate::Routes::Transparent> for some examples. The intention is that routes are as 'thin' as possible: business logic should all be done by some part of the service and not in the route handler. The route handler maps endpoints (URLs) to service requests and serialises the structured response.

B<Routes> pass B<requests> to B<services>. A B<request> contains a B<verb> (like C<create>) and B<data> (like the B<location> you want to create it at and the B<content> you want to place there). See L<Articulate::Request> for more details.

The B<service> is responsible for handling requests for managed content. L<Articulate::Service> B<delegates> to a service B<provider>, asking each in turn if they are willing to handle the request (normally the provider will dertermine this based on the request verb). A provider typically checks a user has suitable permission, then interacts with the content storage system.

B<Storage> is controlled by L<Articulate::Storage>. It delegates to a storage class which is configured for actions like C<get_item> and C<set_meta>.

Content is stored in a structure called an B<item> (see L<Articulate::Item>), which has a C<location> (see L<Articulate::Location>), the B<content> (which could be a binary blob like an image, plain text, markdown, XML, etc.) and the associated B<metadata> or B<meta> (which is a hashref).

Before items can be placed in storage, the service should take care to run them through B<validation>. C<Articulate::Validation> delegates this to validators, and if there are any applicable validators, they will check if the content is valid. The content may also be B<enriched>, i.e. further metadata added, like the time at which the request was made.

If at any time uncaught errors are thrown, including recognised C<Articulate::Error> objects, they are caught and handled by C<Articulate::Service>. C<Articulate::Service> should therefore always return an C<Articulate::Response> object.

Once the request finds it back to the Route it will typically be B<serialised> immediately (see L<Articulate::Serialiser>), and the resulting response passed back to the user.

Finally, after items are retrieved from storage, there is the opportunity to B<augment> them, for instance by including relevant content from elsewhere which belongs in the response. See L<Articulate::Augmentation> for details on this.

=head2 Components

The following classes are persistent, configurable components of the system:

=over

=item * L<Articulate::Augmentation>

=item * L<Articulate::Authentication>

=item * L<Articulate::Construction>

=item * L<Articulate::Enrichment>

=item * L<Articulate::FrameworkAdapter>

=item * L<Articulate::Navigation>

=item * L<Articulate::Serialisation>

=item * L<Articulate::Service>

=item * L<Articulate::Storage>

=item * L<Articulate::Validation>

=back

=head2 Data Classes

The following classes are used for passing request data between components:

=over

=item * L<Articulate::Error>

=item * L<Articulate::Item>

=item * L<Articulate::Location>

=item * L<Articulate::LocationSpecification>

=item * L<Articulate::Permission>

=item * L<Articulate::Request>

=item * L<Articulate::Response>

=back

=head2 Other modules of interest

=over

=item * L<Articulate::Syntax>

=item * L<Articulate::Role::Service>

=back

=head2 Instantiation

Articulate provides a very handy way of creating (or C<instantiating>) objects through your config. The following config, for instance, assignes to the providers attribute (on some other object), an arrayref of four objects, the first created without no arguments, two created with arguments, and a final one created without arguments but using an unusual constructor.

	providers:
		- MyProvider::Simple
		- class: MyProvider::Congfigurable
			args:
				verbose: 1
		- MyProvider::Congfigurable:
				lax: 1
				verbose: 1
		- class: MyProvider::Idiosyncratic
			constuctor: tada

For more details, see L<Articulate::Syntax>.

=head2 Delegation

A key part of the flexibility of Articulate is that objects often B<delegate> functions to other objects (the B<providers>)

Typically, one class delegates to a series of providers, which are each passed the same arguments in turn. L<Articulate::Augmentation> is a good example of this. Sometimes the response from one provider will halt the delegation - see L<Articulate::Authorisation> for an example of this.

Occasionally, only one provider is possible, for instance L<Articulate::FrameworkAdapter>. In this case there is a substitution rather than a delegation.

=head1 BUGS

Bugs should be reported to the L<github issue tracker|https://github.com/pdl/Articulate/issues>. Pull Requests welcome!

=head1 COPYRIGHT

Articulate is Copyright 2014-2015 Daniel Perrett. You are free to use it subject to the same terms as perl: see the LICENSE.txt file included in this distribution for what this means.

Currently Articulate is bundled with versions of other software whose license information you can access from the LICENSE.txt file.

=cut

register articulate_app => sub {
	__PACKAGE__->instance(plugin_setting);
};

sub enable {
	my $self = shift;
	foreach my $route (@{ $self->routes }){
		$route->app($self);
		$route->enable;
	}
	$self->enabled(1);
}

has enabled =>
	is      => 'rw',
	default => sub { 0 };

has routes => (
	is      => 'rw',
	default => sub { [] },
	coerce  => sub { Module::Load::load('Articulate::Syntax'); Articulate::Syntax::instantiate_array ( @_ ) },
	trigger => sub {
		my $self = shift;
		my $orig = shift;
		$_->app($self) foreach @$orig;
	},
);

has components => (
	is      => 'rw',
	default => sub { {} },
	coerce  => sub {
		my $orig = shift;
		Module::Load::load('Articulate::Syntax');
		Articulate::Syntax::instantiate_selection ( $orig );

	},
	trigger => sub {
		my $self = shift;
		my $orig = shift;
		$orig->{$_}->app($self) foreach keys %$orig;
	},
);

register_plugin;

1;
