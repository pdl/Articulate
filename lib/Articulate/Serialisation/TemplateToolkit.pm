package Articulate::Serialisation::TemplateToolkit;

use Moo;
with 'MooX::Singleton';

use Dancer qw(:syntax);

sub serialise {
  my $self     = shift;
  my $response = shift;
  template $response->type, $response->data;
}

1;
