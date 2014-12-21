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

=cut

register articulate_service => sub {
  __PACKAGE__->new;
};

=head3 process_request

  my $response = service->process_request($request);

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
