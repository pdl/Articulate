package Articulate::Navigation;
use strict;
use warnings;

use Moo;
use Dancer::Plugin;
use Articulate::Location;
use Articulate::LocationSpecification;

register navigation => sub {
  __PACKAGE__->new(plugin_setting);
};

#has provider => (is => 'rw',)

has locations => (
  is      => 'rw', # rwp?
  default => sub{ [] },
  coerce  => sub{
    my $orig = shift;
    my $new = [];
    foreach my $l (@{ $orig }){
      push @$new, locspec $l;
    }
    return $new;
  },
);

# A locspec is like a location except it can contain "*": "/zone/*/article/"

sub define_locspec {
  my $self     = shift;
  my $location = locspec shift;
  foreach my $defined_location ( @{ $self->locations } ) {
    if ( ( $location eq $defined_location ) ) {
      return undef;
    }
  }
  push $self->locations, $location;
}

sub undefine_locspec {
  my $self     = shift;
  my $location = locspec shift;
  my ($removed, $kept) = ([], []);
  foreach my $defined_location ( @{ $self->locations } ){
    if ( ( $location eq $defined_location ) or $defined_location->matches_descendant_of($location) ) {
      push $removed, $location;
    }
    else {
      push $kept, $location;
    }
  }
  $self->locations($kept);
  return $removed;
}

sub valid_location {
  my $self     = shift;
  my $location = loc shift;
  foreach my $defined_location ( @{ $self->locations } ) {
    if ( $defined_location->matches($location) ) {
      return $location;
    }
  }
  return undef;
}

register_plugin;

1;
