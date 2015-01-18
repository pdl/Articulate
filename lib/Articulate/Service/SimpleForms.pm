package Articulate::Service::SimpleForms;

use strict;
use warnings;

use Dancer qw(:syntax !after !before); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter
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

sub handle_create_form {
  my $self       = shift;
  my $request    = shift;
  my $user       = $self->framework->user_id;
  my $location   = loc $request->data->{location};
  my $permission = $self->authorisation->permitted ( $user, write => $location );

  if ( $permission ) {

    return response 'form/create', {
      form => {
        location => loc $location, # as string or arrayref?
      },
    };
  }
  else {
    throw_error Forbidden => $permission->reason;
  }

}

sub handle_edit_form {
  my $self    = shift;
  my $request = shift;

  my $location   = loc $request->data->{location};
  my $user       = $self->framework->user_id;
  my $permission = $self->authorisation->permitted ( $user, write => $location );

  if ( $permission ) {

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
    throw_error Forbidden => $permission->reason;
  }

}

sub handle_delete_form {
  my $self    = shift;
  my $request = shift;

  my $item       = $request->data;
  my $location   = $item->location;
  my $user       = $self->framework->user_id;
  my $permission = $self->authorisation->permitted ( $user, write => $location );

  if ( $self->authorisation->permitted ( $user, write => $location ) ) {
    throw_error 'NotFound' unless $self->storage->item_exists($location);

    my $item = $self->storage->get_item($location);
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
    throw_error Forbidden => $permission->reason;
  }

}

1;
