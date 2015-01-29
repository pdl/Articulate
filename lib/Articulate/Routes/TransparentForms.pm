package Articulate::Routes::TransparentForms;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Routes';
use Articulate::Syntax::Routes;
use Articulate::Service;

get '/zone/:zone_id/create' => sub {
  my ($service, $request) = @_;
  my $zone_id    = param ('zone_id');
  $service->process_request(
  create_form => {
    location => "zone/$zone_id",
  }
  )->serialise;
};

post '/zone/:zone_id/create' => sub {
  my ($service, $request) = @_;
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id');
  return $service->process_request( error => {
    simple_message => 'Parameter article_id is required'
  } ) unless defined $article_id and $article_id ne '';
  my $content    = param ('content');
  $service->process_request(
  create => {
    location =>"zone/$zone_id/article/$article_id",
    content  => $content,
  }
  )->serialise;
};


get '/zone/:zone_id/article/:article_id/edit' => sub {
  my ($service, $request) = @_;
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id');
  $service->process_request(
  edit_form => {
    location => "zone/$zone_id/article/$article_id",
  }
  )->serialise;
};

1;
