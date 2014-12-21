package Articulate::Service;

use Dancer::Plugin;

# The following provide plugins which should be singletons within an application
use Articulate::Storage        ();
use Articulate::Authentication ();
use Articulate::Authorisation  ();
use Articulate::Interpreter    ();
use Articulate::Augmentation   ();
use Articulate::Validation     ();

# The following provide objects which must be created on a per-request basis
use Articulate::Location;
use Articulate::Item;
use Articulate::Error;
use Articulate::Request;
use Articulate::Response;

use Moo;
use Try::Tiny;
use Scalar::Util qw(blessed);
use Dancer qw(:syntax); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use DateTime;

sub now {
  DateTime->now;
}

has storage => (
  is      => 'rw',
  default => sub {
    Articulate::Storage::storage;
  }
);

has authentication => (
  is      => 'rw',
  default => sub {
    Articulate::Authentication::authentication;
  }
);

has authorisation => (
  is      => 'rw',
  default => sub {
    Articulate::Authorisation::authorisation;
  }
);

has interpreter => (
  is      => 'rw',
  default => sub {
    Articulate::Interpreter::interpreter;
  }
);

has augmentation => (
  is      => 'rw',
  default => sub {
    Articulate::Augmentation::augmentation;
  }
);

has validation => (
  is      => 'rw',
  default => sub {
    Articulate::Validation::validation;
  }
);




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
  #try {
    if ( ref $underscore[0] ) {
      $request = $underscore[0];
    }
    else { # or accept $verb => $data
      $request = articulate_request (@underscore);
    }
    my $verb  = $request->verb;
    $response = $self->_create($request) if 'create' eq $verb; # todo: delegate this out to providers
    $response = $self->_read($request)   if 'read'   eq $verb; # todo: delegate this out to providers
#  }
#  catch {
#    local $@ = $_;
#    if (blessed $_ and $_->isa('Articulate::Error')) {
#      $response = response error => { error => $_ };
#    }
#    else {
#      $response = response error => { error => Articulate::Error->new( { simple_message => 'Unknown error'. $@ }) };
#    }
#  };
  return $response;
}

sub _create {
  my $self    = shift;
  my $request = shift;
  my $now     = now;

  my $item = blessed $request->data ? $request->data : Articulate::Item->new(
    meta => {
      schema => {
        core => {
          updated => "$now" # ought to stringify # todo: move into item or request
        }
      },
    },
    (%{$request->data} ? %{$request->data} : ()),
  );
  my $location = $item->location;

  my $user       = session ('user');
  my $settings   = $self->storage->get_settings ($location) or throw_error Internal => 'Cannot retrieve settings'; # or throw

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {

    $self->validation->validate  ($item) or throw_error 'The content did not validate'; # or throw

    $self->storage->set_meta    ($item) or throw_error 'Internal'; # or throw
    $self->storage->set_content ($item) or throw_error 'Internal'; # or throw

    $self->interpreter->interpret ($item) or throw_error 'Internal'; # or throw
    $self->augmentation->augment  ($item) or throw_error 'Internal'; # or throw

    return response 'article', {
      article => {
        schema   => $item->meta->{schema},
        content  => $item->content,
        location => $item->location, # as string or arrayref?
      },
    };
  }
  else {
    throw_error 'Forbidden';
  }

}

sub _read {
  my $self     = shift;
  my $request  = shift;
  my $location = loc $request->data->{location};
  my $user     = session ('user_id');
  #my $settings   = $self->storage->get_settings(loc $location) or throw_error Internal => 'Could not retrieve settings'; # or throw
  if ( $self->authorisation->permitted ( $user, read => $location ) ) {
    my $item = Articulate::Item->new(
      meta     => $self->storage->get_meta_cached    ($location),
      content  => $self->storage->get_content_cached ($location),
      location => $location,
    );

    $self->interpreter->interpret ($item) or throw_error; # or throw
    $self->augmentation->augment  ($item) or throw_error; # or throw

    return response article => {
      article => {
        schema  => $item->meta->{schema},
        content => $item->content,
      },
    };
  }
  else {
    return throw_error 'NotPermitted';
  }
}

register_plugin;

1;
