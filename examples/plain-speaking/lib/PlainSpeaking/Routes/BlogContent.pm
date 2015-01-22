package PlainSpeaking::Routes::BlogContent;

use Moo;
with 'Articulate::Role::Routes';

use Dancer qw(:syntax !after !before);
use Articulate::Service;

my $zone_id = 'blog';

my $service = articulate_service;

get '/' => sub {
  my $article_id = param ('article_id');
  $service->process_request(
    list => {
      location => "zone/$zone_id/article",
      sort     => {
        field => "schema/core/dateCreated",
        order => 'desc',
     },
    }
  )->serialise;
};

get '/article/:article_id' => sub {
  my $article_id = param ('article_id');
  $service->process_request(
    read => {
      location => "zone/$zone_id/article/$article_id",
    }
  )->serialise;
};

post '/article/:article_id' => sub {
  my $article_id = param ('article_id');
  my $title      = param ('title');
  my $content    = param ('content');
  $service->process_request(
    update => {
      location => "zone/$zone_id/article/$article_id",
      content  => $content,
      meta     => $title
    }
  )->serialise;
};

get '/login' => sub {
  $service->process_request(
    login_form => {}
  )->serialise;
};

get '/create' => sub {
  $service->process_request(
    create_form => {
      location => "zone/$zone_id",
    }
  )->serialise;
};

post '/create' => sub {
  my $article_id = param ('article_id');
  my $title      = param ('title');
  my $content    = param ('content');
  return $service->process_request( error => {
    simple_message => 'Parameter article_id is required'
  } ) unless defined $article_id and $article_id ne '';
  my $location = "zone/$zone_id/article/$article_id";
  my $response = $service->process_request(
    create => {
      location => $location,
      content  => $content,
      meta     => { schema => { core => { title => $title } } },
    }
  );
  # if ($response) {
  #   $service->process_request(
  #     group_add => {
  #       location => $location,
  #       group    => "zone/$zone_id/group/all",
  #     }
  #   );
  # }
  $response->serialise;
};

post '/preview' => sub {
  my $title      = param ('title');
  my $article_id = param ('article_id');
  return $service->process_request( error => {
    simple_message => 'Parameter article_id is required'
  } ) unless defined $article_id and $article_id ne '';
  my $content    = param ('content');
  $service->process_request(
    preview => {
      location =>"zone/$zone_id/article/$article_id",
      content  => $content,
      meta     => { schema => { core => { title => $title } } },
    }
  )->serialise;
};


get '/article/:article_id/edit' => sub {
  my $article_id = param ('article_id');
  $service->process_request(
    edit_form => {
      location => "zone/$zone_id/article/$article_id",
    }
  )->serialise;
};

get '/upload' => sub {
  $service->process_request(
    upload_form => {
      location => "assets/images",
    }
  )->serialise;
};

post '/upload' => sub {
  my $image_id   = param ('image_id');
  my $title      = param ('title');
  my $content    = upload('image');
  return $service->process_request( error => {
    simple_message => 'Parameter image_id is required'
  } ) unless defined $image_id and $image_id ne '';
  my $location = "assets/images/image/$image_id";
  my $response = $service->process_request(
    create => {
      location => $location,
      content  => $content,
      meta     => {
        schema => {
          core => {
            file => 1,
            content_type => $content->type
          }
        }
      }
    }
  );
  $response->serialise;
};

get '/image/:image_id' => sub {
  my $image_id = param ('image_id');
  $service->process_request(
    read => {
      location => "assets/images/image/$image_id",
    }
  )->serialise;
};

1;
