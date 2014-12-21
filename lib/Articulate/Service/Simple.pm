package Articulate::Service::Simple;

use strict;
use warnings;

use Dancer::Plugin;

# The following provide objects which must be created on a per-request basis
use Articulate::Location;
use Articulate::Item;
use Articulate::Error;
use Articulate::Request;
use Articulate::Response;

use Moo;
with 'Articulate::Role::Service';
use Try::Tiny;
use Scalar::Util qw(blessed);
use Dancer qw(:syntax); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use DateTime;

sub now {
  DateTime->now;
}

use Moo;

sub process_request {
  my $self    = shift;
  my $request = shift;
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(create read);
  return undef; # whatever else the user wants, we can't provide it
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
1;
