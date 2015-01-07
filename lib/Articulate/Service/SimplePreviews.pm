package Articulate::Service::SimplePreviews;

use strict;
use warnings;

use Dancer qw(:syntax !after !before); # we only want session, but we need to import Dancer in a way which doesn't mess with the appdir. Todo: create Articulate::FrameworkAdapter

use Dancer::Plugin;

# The following provide objects which must be created on a per-request basis
# use Articulate::Location;
# use Articulate::Item;
# use Articulate::Error;
use Articulate::Request;
use Articulate::Response;
use Articulate::Syntax;

use Articulate::Construction;

use Moo;
with 'Articulate::Role::Service';
with 'MooX::Singleton';

use Try::Tiny;
use Scalar::Util qw(blessed);

use Moo;

sub process_request {
  my $self    = shift;
  my $request = shift;
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(preview);
  return undef; # whatever else the user wants, we can't provide it
}

sub _preview {
  my $self    = shift;
  my $request = shift;

  my $item = blessed $request->data ? $request->data : construction->construct( {
    (%{$request->data} ? %{$request->data} : ()),
  } );

  my $location = $item->location;

  my $user = session ('user');

  if ( $self->authorisation->permitted ( $user, write => $location ) ) { # no point offering this service to people who can't write there

    $self->validation->validate ($item) or throw_error BadRequest => 'The content did not validate'; # or throw
    $self->enrichment->enrich   ($item, $request); # this will throw if it fails

    # skip the storage interaction

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

1;
