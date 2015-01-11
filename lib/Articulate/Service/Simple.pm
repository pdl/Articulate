package Articulate::Service::Simple;

use strict;
use warnings;

use Dancer::Plugin;

use Articulate::Syntax;

# The following provide objects which must be created on a per-request basis
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

  my $item = blessed $request->data ? $request->data : $self->construction->construct( {
    meta => {},
    (%{$request->data} ? %{$request->data} : ()),
  } );
  my $location = $item->location;

  my $user       = $self->framework->user;
  my $permission = $self->authorisation->permitted ( $user, write => $location );
  if ( $permission ) {

    throw_error 'AlreadyExists' if $self->storage->item_exists($location);

    $self->validation->validate   ($item) or throw_error BadRequest => 'The content did not validate';
    $self->enrichment->enrich     ($item, $request); # this will throw if it fails
    $self->storage->create_item   ($item); # this will throw if it fails

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
    throw_error Forbidden => $permission->reason;
  }

}

sub _read {
  my $self       = shift;
  my $request    = shift;
  my $location   = loc $request->data->{location};
  my $user       = $self->framework->user;
  my $permission = $self->authorisation->permitted ( $user, read => $location );
  if ( $permission ) {
    throw_error 'NotFound' unless $self->storage->item_exists($location);
    my $item = $self->construction->construct( {
      meta     => $self->storage->get_meta_cached    ($location),
      content  => $self->storage->get_content_cached ($location),
      location => $location,
    } );
    $self->augmentation->augment  ($item); # or throw

    return response article => {
      article => {
        schema  => $item->meta->{schema},
        content => $item->content,
      },
    };
  }
  else {
    return throw_error Forbidden => $permission->reason;
  }
}

sub _update {
  my $self    = shift;
  my $request = shift;

  my $item = blessed $request->data ? $request->data : $self->construction->construct( {
    meta => {},
    (%{$request->data} ? %{$request->data} : ()),
  } );
  my $location = $item->location;

  my $user       = $self->framework->user;
  my $permission = $self->authorisation->permitted ( $user, write => $location );
  if ( $permission ) {

    throw_error 'NotFound' unless $self->storage->item_exists($location);

    $self->validation->validate ($item) or throw_error BadRequest => 'The content did not validate'; # or throw
    $self->enrichment->enrich   ($item, $request); # this will throw if it fails
    $self->storage->set_meta    ($item) or throw_error 'Internal'; # or throw
    $self->storage->set_content ($item) or throw_error 'Internal'; # or throw

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
    return throw_error Forbidden => $permission->reason;
  }

}

sub _delete {
  my $self    = shift;
  my $request = shift;

  my $item = $request->data;
  my $location = $item->location;

  my $user       = $self->framework->user;
  my $permission = $self->authorisation->permitted ( $user, write => $location );
  if ( $permission ) {
    throw_error 'NotFound' unless $self->storage->item_exists($location);
    $self->storage->delete_item ($location) or throw_error 'Internal'; # or throw
    return response 'success', { };
  }
  else {
    return throw_error Forbidden => $permission->reason;
  }

}

1;
