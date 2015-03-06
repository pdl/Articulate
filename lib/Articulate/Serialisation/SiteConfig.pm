package Articulate::Serialisation::SiteConfig;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Component';

=head1 NAME

PlainSpeaking::Serialisation::SiteConfig - add some site-wide constants
to your response data

=head1 SYNOPSIS

  components:
    serialisation:
      - Articulate::Serialisation::SiteData:
          site_data:
            # anything you want can go here
            title: My lovely website
            css:
              - base.css
              - print.css
            js:
              - jquery.min.js
              - jquery.ui.min.js
      - Articulate::Serialisation::TemplateToolkit

=head1 METHOD

=head3 serialise

Adds site data to the response data. Returns undef.

=head1 ATTRIBUTE

=head1 site_data

A hashref which will be added to C<< @{ $response->data->{site} } >>.

=cut

has site_data => (
  is      => 'rw',
  default => sub { {} }
);

sub serialise {
  my $self     = shift;
  my $response = shift;
  $response->data->{site} = $self->site_data;
  return undef;
}

1;
