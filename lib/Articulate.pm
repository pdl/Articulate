package Articulate;
use Dancer ':syntax';
use Articulate::Content::Local;
our $VERSION = '0.1';
use DateTime;

sub now {
	DateTime->now;
}


get '/' => sub {
    template 'index';
};

get '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	
	my $location = "zone/$zone_id/article/$article_id";
	my $meta     = get_meta    ($location) or die; # or throw
	my $content  = get_content ($location) or die; # or throw
	
    template 'article', {
		article => {
			schema  => $meta->{schema},
			content => $content,
		},
	};
};

post '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $content    = param ('content');
	my $now        = now;
	
	my $meta = {
		schema => {
			core => {
				updated => "$now" # ought to stringify
			}
		}
	};
	
	my $location = "zone/$zone_id/article/$article_id";
	
	set_meta    ($location, $meta)    or die; # or throw
	set_content ($location, $content) or die; # or throw
    template 'article', {
		article => {
			schema  => $meta->{schema},
			content => $content,
		},
	};
};

1;
