package Articulate;
use Dancer::Plugin;
use Articulate::Service;
use Module::Load ();
our $VERSION = '0.001';

=head1 NAME

Articulate - A lightweight Perl CMS Framework

=head1 SYNOPSIS

	# (in bin/app.pl)
	use Dancer;
	articulate_app->enable;
	dance;

Articulate provides a content management service for your web app. Lightweight means placing minimal demands on your app while maximising 'whipuptitude': it gives you a single interface in code to a framework that's totally modular underneath, and it won't claim any URL endpoints for itself.

You don't need to redesign your app around Articulate, it's a service that you call on when you need it, and all the 'moving parts' can be switched out if you want to do things your way.

It's written in Perl, the fast, reliable 'glue language' that's perfect for agile web development projects.

=head1 DESCRIPTION

Articulate is (currently) a set of Dancer plugins which work together to create a conent management service that will sit alongside an existing Dancer app or for the basis of a new one.

=head2 Response/Request lifecycle summary

In a B<route>, you parse user input and pick the parameters you want to send to the service. Have a look at L<Articulate::Routes::Transparent> for some examples. The intention is that routes are as 'thin' as possible: business logic should all be done by some part of the service and not in the route handler. The route handler maps endpoints (URLs) to service requests and serialises the structured response.

A B<request> contains a B<verb> (like C<create>) and B<data> (like the B<location> you want to create it at and the B<content> you want to place there). See L<Articulate::Request> for more details.

The B<service> is responsible for handling requests for managed content. L<Articulate::Service> B<delegates> to a service B<provider>, asking each in turn if they are willing to handle the request (normally the provider will dertermine this based on the request verb). A provider typically checks a user has suitable permission, then interacts with the content storage system.

B<Storage> is controlled by L<Articulate::Storage>. It delegates to a storage class which is configured for actions like C<get_item> and C<set_meta>.

Content is stored in a structure called an B<item> (see L<Articulate::Item>), which has a C<location> (see L<Articulate::Location>), the B<content> (which could be a binary blob like an image, plain text, markdown, XML, etc.) and the associated B<metadata> or B<meta> (which is a hashref).

Before items can be placed in storage, the service should take care to run them through B<validation>. C<Articulate::Validation> delegates this to validators, and if there are any applicable validators, they will check if the content is valid.

If at any time uncaught errors are thrown, including recognised C<Articulate::Error> objects, they are caught and handled by C<Articulate::Service>. C<Articulate::Service> should therefore always return an C<Articulate::Response> object.

Once the request finds it back to the Route it will typically be B<serialised> immediately (see L<Articulate::Serialiser>), and the resulting response passed back to the user.

Finally, after items are retrieved from storage, there is the opportunity to C<augment> them, for instance by including relevant content from elsewhere which belongs in the response. See L<Articulate::Augmentation> for details on this.

=head2 Components

The following classes are persistent, configurable components of the system

=over

=item * L<Articulate::Augmentation>

=item * L<Articulate::Authentication>

=item * L<Articulate::Intepreter>

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

=item * L<Articulate::Request>

=item * L<Articulate::Response>

=back

=head1 BUGS

Bugs should be reported to the L<github issue tracker|https://github.com/pdl/Articulate/issues>. Pull Requests welcome!

=head1 COPYRIGHT

Articulate is Copyright 2014 Daniel Perrett. You are free to use it subject to the same terms as perl: see the LICENSE.txt file included in this distribution for what this means

Currently Articulate is bundled with versions of other software whose license information you can access from the LICENSE.txt file.

=cut

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
