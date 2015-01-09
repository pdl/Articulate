package Articulate::Service::List;

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

sub process_request {
  my $self    = shift;
  my $request = shift;
  $request->verb eq $_ ? return $self->${\"_$_"}($request) : 0 for qw(list);
  return undef; # whatever else the user wants, we can't provide it
}

sub _list {
  my $self    = shift;
  my $request = shift;

  my $location = loc $request->data->{location};
  my $sort     = $request->data->{sort};

  my $get_sort_field = sub {
    my $meta = shift->meta;
    my $curr = [$meta];
    foreach my $key ( split qr~/~, $sort->{field} ) {
      return '' unless exists $curr->[0]->{$key};
      $curr = [ $curr->[0]->{$key} ];
    }
    return $curr->[0];
  };

  my $user       = session ('user');

  if ( $self->authorisation->permitted ( $user, read => $location ) ) {
    my $items = [];
    foreach my $item_location (map { loc "$location/$_" } $self->storage->list_items($location)) {
      if ( $self->authorisation->permitted ( $user, read => $item_location ) ) {
        my $item = $self->construction->construct( {
          location => $location,
          meta     => $self->storage->get_meta($item_location),
          content  => $self->storage->get_content($item_location),
        } );
        $self->interpreter->interpret ($item); # this will throw if it fails
        $self->augmentation->augment  ($item); # this will throw if it fails
        push $items, $item;
      }
    }
    return response 'list', {
      list => [
        map {
          {
            is       => 'article',
            location => $_->location,
            schema   => $_->meta->{schema},
            content  => $_->content,
          }
        } sort { ( $get_sort_field->($a) cmp $get_sort_field->($b) ) * ( ( $sort->{order} // 'asc' ) eq 'desc' ? -1 : 1 ) } @$items # would benefit from a schwartzian transform here
      ],
    };
  }
  else {
    throw_error 'Forbidden';
  }

}


1;
