package Articulate::Routes::Transparent;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Routes';
use Articulate::Syntax::Routes;
use Articulate::Service;

get '/zone/:zone_id/article/:article_id' => sub {
  my ($service, $request) = @_;
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id');
  $service->process_request(
  read => {
    location => "zone/$zone_id/article/$article_id",
  }
  )->serialise;
};

post '/zone/:zone_id/article/:article_id' => sub {
  my ($service, $request) = @_;
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id');
  my $content    = param ('content');
  $service->process_request(
  create => {
    location =>"zone/$zone_id/article/$article_id",
    content  => $content,
  }
  )->serialise;
};

post '/zone/:zone_id/article/:article_id/edit' => sub {
  my ($service, $request) = @_;
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id');
  my $content    = param ('content');
  $service->process_request(
  update => {
    location =>"zone/$zone_id/article/$article_id",
    content  => $content,
  }
  )->serialise;
};

1;
