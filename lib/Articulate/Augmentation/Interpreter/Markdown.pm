package Articulate::Augmentation::Interpreter::Markdown;
use strict;
use warnings;

use Text::Markdown;
use Moo;

=head1 NAME

Articulate::Augmentation::Interpreter::Markdown - convert markdown to HTML

=head1 METHODS

=head3 augment

Converts markdown in the content of the response into HTML.

=cut

has markdown_parser =>
  is      => 'rw',
  lazy    => 1,
  default => sub {
    my $self = shift;
    Text::Markdown->new (%{ $self->markdown_parser_options });
  }
;

has markdown_parser_options =>
  is      => 'rw',
  default => sub {
    {}
  }
;

sub augment {
  my $self = shift;
  my $item = shift;
  $item->content (
    $self->markdown_parser->markdown($item->content)
  );
  return $item;
}

1;
