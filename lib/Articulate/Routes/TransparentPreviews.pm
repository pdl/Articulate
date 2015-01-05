package Articulate::Routes::TransparentPreviews;

use Moo;
with 'Articulate::Role::Routes';

use Dancer qw(:syntax !after !before);
use Articulate::Service;
use Articulate::Error;

my $service = articulate_service;

post '/zone/:zone_id/preview' => sub {
  my $zone_id    = param ('zone_id');
  my $article_id = param ('article_id') // throw_error BadRequest => "article_id must be specified"; # todo: capture and serialise
  my $content    = param ('content');
  $service->process_request(
    preview => {
      location =>"zone/$zone_id/article/$article_id",
      content  => $content,
    }
  )->serialise;
};

1;
