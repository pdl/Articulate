package Articulate::Routes::TransparentPreviews;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Routes';
use Articulate::Syntax::Routes;
use Articulate::Service;

my $service = articulate_service;

post '/zone/:zone_id/preview' => sub {
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id');
  return $service->process_request( error => {
    simple_message => 'Parameter article_id is required'
  } ) unless defined $article_id and $article_id ne '';
  my $content    = param ('content');
  $service->process_request(
    preview => {
      location =>"zone/$zone_id/article/$article_id",
      content  => $content,
    }
  )->serialise;
};

1;
