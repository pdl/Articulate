package Articulate::Interpreter::Markdown;
use Text::Markdown;
use Moo;
with 'MooX::Singleton';

=head1 NAME

Articulate::Interpreter::Markdown - convert markdown to HTML

=head1 METHODS

=head3 interpret

Converts markdown in the content of the response into HTML.

=cut

has markdown_parser =>
  is => 'rw',
  default => sub {
    Text::Markdown->new ();
  }
;

sub interpret {
  my $self = shift;
  my $item = shift;
  $item->content (
    $self->markdown_parser->markdown($item->content)
  );
  return $item;
}

1;
