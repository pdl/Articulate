package Articulate::Service;

use Dancer::Plugin;

# The following provide objects which must be created on a per-request basis
use Articulate::Location;
use Articulate::Item;
use Articulate::Error;
use Articulate::Request;
use Articulate::Response;

use Moo;
with 'MooX::Singleton';
with 'Articulate::Role::Service';
use Try::Tiny;
use Scalar::Util qw(blessed);
use Dancer qw(:syntax); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use DateTime;

sub now {
  DateTime->now;
}

=head1 NAME

Articulate::Service - provide an API to all the core Articulate features.

=cut

=head1 DESCRIPTION

The Articulate Service provides programmatic access to all the core features of Articulate.

Mostly, you will want to be calling the service in routes, for instance:

  get 'zone/:zone_name/article/:article_name' => sub{
    my ($zone_name, $article_name) = param('zone_name'), param('article_name');
    $service->process_request ( read => "/zone/$zone_name/article/$article_name' )->serialise;
  }

However, you may also want to call it from one-off scripts, tests, etc., especially where you want to perform tasks which you don't want to make available in routes, or where you are already in a perl environment and mapping to the HTTP layer would be a distraction. In theory you could create an application which did not have any web interface at all using this service, e.g. a command-line app on a shared server.

=cut

register articulate_service => sub {
  __PACKAGE__->new;
};

=head3 process_request

  my $response = service->process_request($request);
  my $response = service->process_request($verb => $data);

This is the primary method of the service: Pass in an Articulate::Request object and the Service will produce a Response object to match.

Alternatively, if you pass a string as the first argument, the request will be created from the verb and the data.

Which verbs are handled, what data they require, and how they will be processed are determined by the service providers you have set up in your config: C<process_request> passes the request to each of the providers in turn and asks them to process the request.

Providers can decline to process the request by returning undef, which will cause the service to offer the requwst to the next provider.

Note that a provider MAY act on a request and still return undef, e.g. to perform logging, however it is discouraged to perform acctions which a user would typically expect a response from (e.g. a create action should return a response and not just pass to a get to confirm it has successfully created what it was suppsed to).

=cut

use YAML;

sub process_request {
  my $self = shift;
  my @underscore = @_; # because otherwise the try block will eat it
  my $request;
  my $response = response error => { error => Articulate::Error::NotFound->new( { simple_message => 'No appropriate Service Provider found' } ) };
  try {
    if ( ref $underscore[0] ) {
      $request = $underscore[0];
    }
    else { # or accept $verb => $data
      $request = articulate_request (@underscore);
    }
    use Articulate::Service::Simple;
    foreach my $provider (
      # @{ $service->providers }
      Articulate::Service::Simple->new  # for now
    ) {
      my $resp = $provider->process_request($request);
      if (defined $resp) {
        $response = $resp;
        last;
      }
    }
  }
  catch {
    local $@ = $_;
    if (blessed $_ and $_->isa('Articulate::Error')) {
      $response = response error => { error => $_ };
    }
    else {
      $response = response error => { error => Articulate::Error->new( { simple_message => 'Unknown error'. $@ }) };
    }
  };
  return $response;
}

register_plugin;

1;
