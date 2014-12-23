package Articulate::Serialisation::TemplateToolkit;

use Moo;
with 'MooX::Singleton';

=head1 NAME

Articulate::Serialisation::TemplateToolkit - put your response into a TT2 template

=head1 METHODS

=head3 serialise

Finds the template corresponding to the response type and processes it, passing in the response data.

=cut


use Dancer qw(:syntax);

sub serialise {
  my $self     = shift;
  my $response = shift;
  template $response->type, $response->data;
}

1;
