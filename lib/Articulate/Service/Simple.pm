package Articulate::Service::Simple;

use strict;
use warnings;

use Dancer qw(:syntax !after !before); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use Dancer::Plugin;

# The following provide objects which must be created on a per-request basis
use Articulate::Location;
use Articulate::Item;
use Articulate::Error;
use Articulate::Request;
use Articulate::Response;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

use Try::Tiny;
use Scalar::Util qw(blessed);

use Moo;

sub process_request {
  my $self    = shift;
  my $request = shift;
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(create read update delete);
  return undef; # whatever else the user wants, we can't provide it
}

sub _create {
  my $self    = shift;
  my $request = shift;

  my $item = blessed $request->data ? $request->data : Articulate::Item->new(
    meta => {},
    (%{$request->data} ? %{$request->data} : ()),
  );
  my $location = $item->location;

  my $user       = session ('user');

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {

    throw_error 'AlreadyExists' if $self->storage->item_exists($location);

    $self->validation->validate   ($item) or throw_error BadRequest => 'The content did not validate';
    $self->enrichment->enrich     ($item, $request); # this will throw if it fails
    $self->storage->create_item   ($item); # this will throw if it fails

    $self->interpreter->interpret ($item); # this will throw if it fails
    $self->augmentation->augment  ($item); # this will throw if it fails

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

  if ( $self->authorisation->permitted ( $user, read => $location ) ) {
    throw_error 'NotFound' unless $self->storage->item_exists($location);
    my $item = Articulate::Item->new(
    meta     => $self->storage->get_meta_cached    ($location),
    content  => $self->storage->get_content_cached ($location),
    location => $location,
    );

    $self->interpreter->interpret ($item); # or throw
    $self->augmentation->augment  ($item); # or throw

    return response article => {
      article => {
        schema  => $item->meta->{schema},
        content => $item->content,
      },
    };
  }
  else {
    return throw_error 'Forbidden';
  }
}

sub _update {
  my $self    = shift;
  my $request = shift;

  my $item = blessed $request->data ? $request->data : Articulate::Item->new(
    meta => {},
    (%{$request->data} ? %{$request->data} : ()),
  );
  my $location = $item->location;

  my $user       = session ('user');

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {

    throw_error 'NotFound' unless $self->storage->item_exists($location);

    $self->validation->validate ($item) or throw_error BadRequest => 'The content did not validate'; # or throw
    $self->enrichment->enrich   ($item, $request); # this will throw if it fails
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

sub _delete {
  my $self    = shift;
  my $request = shift;

  my $item = $request->data;
  my $location = $item->location;

  my $user       = session ('user');

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {
    throw_error 'NotFound' unless $self->storage->item_exists($location);
    $self->storage->delete_item ($location) or throw_error 'Internal'; # or throw
    return response 'success', { };
  }
  else {
    throw_error 'Forbidden';
  }

}

1;
