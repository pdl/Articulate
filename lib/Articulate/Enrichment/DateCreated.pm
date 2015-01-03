package Articulate::Enrichment::DateCreated;
use Text::Markdown;
use Moo;
with 'MooX::Singleton';

=head1 NAME

Articulate::Enrichment::DateCreated - add a creation date to the meta

=head1 METHODS

=head3 enrich

Sets the creation date (C<meta.schema.core.dateCreated>) to the current time, provided the request verb begins with C<create>.

=cut

use DateTime;

sub now {
  DateTime->now;
}

sub enrich {
  my $self    = shift;
  my $item    = shift;
  my $request = shift;
  if ( $request->verb =~ /^create/ ) {
    my $now = now;
    $item->meta->{schema}->{core}->{dateCreated} = "$now";
    return $item;
  }
}

1;
