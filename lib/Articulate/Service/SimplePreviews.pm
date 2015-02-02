package Articulate::Service::SimplePreviews;

use strict;
use warnings;

use Articulate::Syntax;

# The following provide objects which must be created on a per-request basis
use Articulate::Request;
use Articulate::Response;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

use Try::Tiny;
use Scalar::Util qw(blessed);

sub handle_preview {
  my $self    = shift;
  my $request = shift;

  my $item = blessed $request->data ? $request->data : $self->construction->construct( {
    (%{$request->data} ? %{$request->data} : ()),
  } );

  my $location = $item->location;

  my $user       = $self->framework->user_id;
  my $permission = $self->authorisation->permitted ( $user, write => $location );

  if ( $permission ) { # no point offering this service to people who can't write there

    $self->validation->validate ($item) or throw_error BadRequest => 'The content did not validate'; # or throw
    $self->enrichment->enrich   ($item, $request); # this will throw if it fails

    # skip the storage interaction
    my $item_class = $item->location->[-2];

    $self->augmentation->augment  ($item_class); # this will throw if it fails

    return response $item_class, {
      $item_class => {
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
