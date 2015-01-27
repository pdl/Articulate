package Articulate::Serialisation::TemplateToolkit;
use strict;
use warnings;

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
  my $view = $response->type . '.tt';
  my $template_engine = Dancer::Template->engine;
  #if ( $template_engine->view_exists( $template_engine->view($view) ) ) {
    template $view, $response->data;
  #}
  #else {
  #  status 500;
  #  template error => { error => { simple_message => "View $view not found", http_status => 500} };
  #}
}

1;
