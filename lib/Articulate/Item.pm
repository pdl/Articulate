package Articulate::Item;
use strict;
use warnings;
use Moo;

=head1 NAME

Articulate::Item - represent an item

=cut

=head1 METHODS

=head3 location

Returns the location of the item, as a location object (see L<Articulate::Location>). Coerces into a location using C<Articulate::Location::loc>.

=cut

has location => (
  is      => 'rw',
  default => sub { Articulate::Location->new; },
  coerce  => sub { Articulate::Location::loc(shift); }
);

=head3 meta

Returns the item's metadata, as a hashref.

=cut

has meta => (
  is      => 'rw',
  default => sub { {} },
);

=head3 content

Returns the item's content. What it might look like depends entirely on the content. Typically this is an unblessed scalar value, but it MAY contain binary data or an L<Articulate::File> object.

=cut

has content => (
  is      => 'rw',
  default => sub { '' },
);

1;
