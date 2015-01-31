package Articulate::Storage::Common;
use strict;
use warnings;

use Exporter::Declare;
use Articulate::Navigation;

default_exports qw(
  good_location
  merge_settings
);

=head1 NAME

Articulate::Storage::Common - provides common functions for use in storage classes

=cut


# This generates re_location, a regular expression for all possible locations

my $re_location;
my $s_slug  = '[a-zA-Z0-9](?:|[a-zA-Z0-9\-]*[a-zA-Z0-9])';
my $re_slug = qr~$s_slug~;
{
  my $path_schema = {
    zone => {
      article => {
        # ...
      },
    },
    user => {},
  };
  my $_descend;
  $_descend = sub {
    my ($current, $stack) = @_;
    my $paths = [$stack];
    foreach my $key (keys %$current) {
      push @$paths, @{ $_descend->( $current->{$key}, [@$stack, $key] ) };
    }
    $paths;
  };
  my $s_location = '';
  foreach my $path ( @{ $_descend->( $path_schema, [] ) } ) {
    $s_location .= '|^';
    foreach my $step (@$path) {
      $s_location .= "$step(?:/$s_slug)?/";
    }
    $s_location =~ s~/$~~;
    $s_location .= '$';
  }
  $s_location =~ s~^\|~~;
  $re_location = qr/$s_location/;
}
#die $re_location;

sub good_location {
  my $location  = shift;
  return Articulate->instance->components->{'navigation'}->valid_location($location);
  return undef unless $location =~ $re_location;#m~^zone/$re_slug/article/$re_slug$~;
  return $location;
}



=head3 merge_settings

my $merged = merge_settings ($parent, $child);

=cut

sub merge_settings {
  my ($parent, $child) = @_;
  return {%$parent, %$child}; # todo: more
}
