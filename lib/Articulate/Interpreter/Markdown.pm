package Articulate::Interpreter::Markdown;
use Text::Markdown;
use Moo;

has markdown_parser =>
  is => 'rw',
  default => sub {
    Text::Markdown->new ();
  }
;

sub interpret {
  my $self = shift;
  my $meta = shift;
  my $content = shift;

  return (
    $meta, #"<h4>Yeah, we'll get to this later...</h4>"
    $self->markdown_parser->markdown($content)
  );

}

1;
