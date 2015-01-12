package Articulate::LocationSpecification;
use Moo;
use Scalar::Util qw(blessed);
use overload  '""' => \&to_file_path, '@{}' => sub{ shift->path };
use Dancer::Plugin ();
use Articulate::Location;

=head1 NAME

Articulate::Location - represent an item's location

=cut

=head1 DESCRIPTION

  loc ['zone', 'public', 'article', 'hello-world']
  loc 'zone/public/article/hello-world' # same thing

An object class which represents an item's location within the Articulate ecosystem. It contains an array of slugs, and stringifies to the 'file path' representation of them.

=cut

=head1 FUNCTIONS

=head3 loc

C<loc> is a constructor. It takes either a string (in the form of a path) or an arrayref. Either will be stored as an arrayref in the C<path> attribute.

=cut

Dancer::Plugin::register locspec => sub {
  if ( 1 == scalar @_ ) {
    if ( blessed $_[0] and $_[0]->isa('Articulate::LocationSpecification') ) {
      return $_[0];
    }
    elsif ( blessed $_[0] and $_[0]->isa('Articulate::Location') ) {
      my $path = $_[0]->path; # should this logic be in the coerce?
      if (@$path) {
        for my $i (1..$#$path) {
          if (0 == ($i % 2) ) {
            $path->[$i] = '*';
          }
        }
      }
      return __PACKAGE__->new({ path => $path });
    }
    elsif ( ref $_[0] eq 'ARRAY' ) {
      return __PACKAGE__->new({ path => $_[0] });
    }
    elsif ( !defined $_[0] ) {
      return __PACKAGE__->new;
    }
    elsif ( !ref $_[0] ) {
      return __PACKAGE__->new({ path => [ grep { $_ ne '' } split /\//, $_[0] ] });
    }
    elsif ( ref $_[0] eq 'HASH' ) {
      return __PACKAGE__->new($_[0]);
    }
  }
};

=head1 METHODS

=head3 path

An arrayref representing the path to the location. This is used for overloaded array dereferencing.

=cut

has path => (
  is      => 'rw',
  default => sub { []; },
);

=head3 location

  $location->location->location # same as $location

This method always returns the object itself.

=cut


sub location {
  return shift;
}

=head3 to_file_path

Joins the contents of C<path> on C</> and returns the result. This is used for overloaded stringification.

=cut

sub to_file_path {
  return join '/', @{ $_[0]->path }
};

sub _step_matches {
  my ( $left, $right ) = @_;
  return 1 if ( $left  eq '*' );
  return 1 if ( $right eq '*' );
  return 1 if ( $left  eq $right );
  return 0;

}

sub matches {
  my $self     = shift;
  my $location = loc shift;
  return 0 unless $#$self == $#$location;
  return 1 if $#$self == -1; # go no further if both are empty
  for my $i (0..$#$self) {
    return 0 unless _step_matches( $self->[$i], $location->[$i] );
  }
  return 1;
}
# sub matches_parent_of {
#
# }
# sub matches_child_of {
#
# }
sub matches_ancestor_of {
  my $self     = shift;
  my $location = loc shift;
  return 0 unless $#$self <= $#$location;
  return 1 if $#$self == -1; # go no further if self is empty
  for my $i (0..$#$self) {
    return 0 unless _step_matches( $self->[$i], $location->[$i] );
  }
  return 1;
}

sub matches_descendant_of {
  my $self     = shift;
  my $location = loc shift;
  return 0 unless $#$self >= $#$location;
  return 1 if $#$location == -1; # go no further if self is empty
  for my $i (0..$#$self) {
    return 0 unless _step_matches( $self->[$i], $location->[$i] );
  }
  return 1;
}

Dancer::Plugin::register_plugin;

1;
