package PlainSpeaking::Routes::BlogContent;

use Moo;
with 'Articulate::Role::Routes';

use Articulate::Syntax::Routes;
use Articulate::Service;

my $zone_id = 'blog';

get '/' => sub {
  my $self    = shift;
  my $request    = shift;
  my $article_id = $request->params->{'article_id'};
  $self->process_request(
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
  my $self    = shift;
  my $request    = shift;
  my $article_id = $request->params->{'article_id'};
  $self->process_request(
    read => {
      location => "zone/$zone_id/article/$article_id",
    }
  )->serialise;
};

post '/article/:article_id' => sub {
  my $self    = shift;
  my $request    = shift;
  my $article_id = $request->params->{'article_id'};
  my $title      = $request->params->{'title'};
  my $content    = $request->params->{'content'};
  $self->process_request(
    update => {
      location => "zone/$zone_id/article/$article_id",
      content  => $content,
      meta     => $title
    }
  )->serialise;
};

get '/login' => sub {
  my $self    = shift;
  my $request    = shift;
  $self->process_request(
    login_form => {}
  )->serialise;
};

get '/create' => sub {
  my $self    = shift;
  my $request    = shift;
  $self->process_request(
    create_form => {
      location => "zone/$zone_id",
    }
  )->serialise;
};

post '/create' => sub {
  my $self    = shift;
  my $request    = shift;
  my $article_id = $request->params->{'article_id'};
  my $title      = $request->params->{'title'};
  my $content    = $request->params->{'content'};
  return $self->process_request( error => {
    simple_message => 'Parameter article_id is required'
  } ) unless defined $article_id and $article_id ne '';
  my $location = "zone/$zone_id/article/$article_id";
  my $response = $self->process_request(
    create => {
      location => $location,
      content  => $content,
      meta     => { schema => { core => { title => $title } } },
    }
  );
  # if ($response) {
  #   $self->process_request(
  #     group_add => {
  #       location => $location,
  #       group    => "zone/$zone_id/group/all",
  #     }
  #   );
  # }
  $response->serialise;
};

post '/preview' => sub {
  my $self    = shift;
  my $request    = shift;
  my $title      = $request->params->{'title'};
  my $article_id = $request->params->{'article_id'};
  return $self->process_request( error => {
    simple_message => 'Parameter article_id is required'
  } ) unless defined $article_id and $article_id ne '';
  my $content    = $request->params->{'content'};
  $self->process_request(
    preview => {
      location =>"zone/$zone_id/article/$article_id",
      content  => $content,
      meta     => { schema => { core => { title => $title } } },
    }
  )->serialise;
};


get '/article/:article_id/edit' => sub {
  my $self    = shift;
  my $request    = shift;
  my $article_id = $request->params->{'article_id'};
  $self->process_request(
    edit_form => {
      location => "zone/$zone_id/article/$article_id",
    }
  )->serialise;
};

get '/upload' => sub {
  my $self    = shift;
  my $request    = shift;
  $self->process_request(
    upload_form => {
      location => "assets/images",
    }
  )->serialise;
};

post '/upload' => sub {
  my $self    = shift;
  my $request    = shift;
  my $image_id   = $request->params->{'image_id'};
  my $title      = $request->params->{'title'};
  my $content    = $request->upload('image');
  return $self->process_request( error => {
    simple_message => 'Parameter image_id is required'
  } ) unless defined $image_id and $image_id ne '';
  my $location = "assets/images/image/$image_id";
  my $response = $self->process_request(
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
  my $self    = shift;
  my $request    = shift;
  my $image_id = $request->params->{'image_id'};
  $self->process_request(
    read => {
      location => "assets/images/image/$image_id",
    }
  )->serialise;
};

1;
