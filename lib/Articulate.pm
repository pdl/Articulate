package Articulate;
use Dancer ':syntax';
use Articulate::Content::Local;
our $VERSION = '0.1';
use DateTime;

sub now {
	DateTime->now;
}

sub respond {
	template @_;
}

sub has_write_permissions {1}

sub has_read_permissions  {1}


get '/' => sub {
    template 'index';
};

get '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $user       = session ('user');

	my $location   = "zone/$zone_id/article/$article_id";
	my $meta       = get_meta     ($location) or die; # or throw
	my $settings   = get_settings ($location) or die; # or throw
	my $content    = get_content  ($location) or die; # or throw

	if ( has_read_permissions ($user, $settings) ) {
	  respond article => {
			article => {
				schema  => $meta->{schema},
				content => $content,
			},
		};
	}
};

post '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $content    = param ('content');
	my $now        = now;
	my $user       = session ('user');
	my $location   = "zone/$zone_id/article/$article_id";
	my $settings   = get_settings ($location) or die; # or throw

	if ( has_write_permissions ($user, $settings) ) {
		my $meta = {
			schema => {
				core => {
					updated => "$now" # ought to stringify
				}
			}
		};

		set_meta    ($location, $meta)    or die; # or throw
		set_content ($location, $content) or die; # or throw

	  respond 'article', {
			article => {
				schema  => $meta->{schema},
				content => $content,
			},
		};
	}
	else {
		die '403';
	}
};

1;
