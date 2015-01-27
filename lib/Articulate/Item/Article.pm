package Articulate::Item::Article;
use strict;
use warnings;

use Moo;
extends 'Articulate::Item';
#with 'Articulate::Role::Item::Format';

sub original_format {
  my $write = $#_;
  my $self = shift;
  if ($write) {
    my $val = shift;
    $self->meta->{schema}->{core}->{originalFormat} = $val;
  }
  else {
    return $self->meta->{schema}->{core}->{originalFormat}; # todo: capacity for setting defaults
  }
};

sub article_id {
  my $self = shift;
  $self->location->[-1];
}

1;
