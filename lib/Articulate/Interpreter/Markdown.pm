package Articulate::Interpreter::Markdown;
use Text::Markdown;
use Moo;
with 'MooX::Singleton';

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
