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

=head3 _meta_accessor

  # In a subclass of Item
  sub author { shift->meta_accessor('schema/article/author')->(@_) }

  # Then, on that subclass
  $article->author('user/alice');
  $article->author;

Uses dpath_set or dpath_get from L<Atticulate::Syntax> to find or assign the relevant field in the metadata.

=cut

sub _meta_accessor {
  my $self = shift;
  my $path = shift;
  return sub {
    if (@_) {
      dpath_set ($self->meta, $path, @_)
    }
    else {
      dpath_get ($self->meta, $path)
    }
  }
}


1;
