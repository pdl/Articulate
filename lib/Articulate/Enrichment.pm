package Articulate::Enrichment;

use Moo;
with 'MooX::Singleton';
use Dancer::Plugin;
use Articulate::Syntax qw(instantiate_array);

=head1 NAME

Articulate::Enrichment - tidy up your content before it goes into the database

=head1 DESCRIPTION

  use Articulate::Enrichment;
  $request = enrichment->enrich($item, $request);

This will pass the item and the request to a series of enrichment objects, each of which has the opportunity to alter the item according to their own rules, for instance, to add an 'updated on' date to the meta or to fix minor errors in the content.

Services should typically invoke enrichment when they create or update content, after validation but before storage.

Note: the item passed in is not cloned so this will typically mutate the item.

Enrichments should not mutate the request, however there is no technical barrier to them doing so.

=head1 FUNCTION

=head3 enrichment

This is a functional constructor: it returns an Articulate::Enrichment object.

=cut

register enrichment => sub {
  __PACKAGE__->instance(plugin_setting);
};

=head1 ATTRIBUTES

=head3 enrichments

An array of the enrichment classes which will be used.

=cut

has enrichments =>
  is      => 'rw',
  default => sub { [] },
  coerce  => sub { instantiate_array(@_) };

=head1 METHODS

=head3 enrich

Passes the item and request objects to a series of enrichment objects, and returns the item after each has done their bit.

=cut

sub enrich {
  my $self    = shift;
  my $item    = shift;
  my $request = shift;
  foreach my $enrichment ( @{ $self->enrichments } ) {
    $request = $enrichment->enrich($item, $request);
  }
  return $item;
}

register_plugin();

1;
