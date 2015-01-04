package Articulate::Service::SimpleForms;

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
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(create_form edit_form delete_form);
  return undef; # whatever else the user wants, we can't provide it
}

sub _create_form {
  my $self     = shift;
  my $request  = shift;
  my $user     = session ('user');
  my $location = loc $request->data->{location};

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {

    return response 'form/create', {
      form => {
        location => loc $location, # as string or arrayref?
      },
    };
  }
  else {
    throw_error 'Forbidden';
  }

}

sub _edit_form {
  my $self    = shift;
  my $request = shift;

  my $location = loc $request->data->{location};

  my $user       = session ('user');

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {

    throw_error 'NotFound' unless $self->storage->item_exists($location);

    my $item = $self->storage->get_item($location);

    # we don't want to interpret at this point

    return response 'form/edit', {
      raw => {
        meta     => $item->meta,
        content  => $item->content,
        location => $item->location, # as string or arrayref?
      },
    };
  }
  else {
    throw_error 'Forbidden';
  }

}

sub _delete_form {
  my $self    = shift;
  my $request = shift;

  my $item = $request->data;
  my $location = $item->location;

  my $user       = session ('user');

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {
    throw_error 'NotFound' unless $self->storage->item_exists($location);

    my $item = $self->storage->get_item($location);
    $self->interpreter->interpret ($item) or throw_error 'Internal'; # or throw
    $self->augmentation->augment  ($item) or throw_error 'Internal'; # or throw

    return response 'form/delete', {
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

1;
