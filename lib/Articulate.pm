package Articulate;
use Dancer ':syntax';
use Articulate::Storage;
use Articulate::Authentication;
use Articulate::Authorisation;
use Articulate::Interpreter;
use Articulate::Location;
use Articulate::Item;
use Articulate::Augmentation;
use Articulate::Validation;
our $VERSION = '0.1';
use DateTime;

sub now {
	DateTime->now;
}

my $storage = storage;

sub respond {
	my ($response_type, $response_data) = @_;
	$response_data //= {};
	if (0) { # API
		return $response_data;
	}
	else {
		return template $response_type => {
			%$response_data,
			page => {
				served => now,
			},
			session => {
				user_id => session('user_id'),
			},
		};
	}
}

get '/' => sub {
    template 'index';
};

get '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $user       = session ('user_id');

	my $location   = loc "zone/$zone_id/article/$article_id";

	my $settings   = $storage->get_settings(loc $location) or die; # or throw

	if ( authorisation->permitted ( $user, read => $location ) ) {
		my $item = Articulate::Item->new(
			meta     => $storage->get_meta_cached    ($location),
			content  => $storage->get_content_cached ($location),
			location => $location,
		);

		interpreter->interpret ($item) or die; # or throw
		augmentation->augment  ($item) or die; # or throw

	  respond article => {
			article => {
				schema  => $item->meta->{schema},
				content => $item->content,
			},
		};
	}
	else {
		return die '403';
	}
};

post '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $content    = param ('content');
	my $now        = now;
	my $user       = session ('user');
	my $location   = "zone/$zone_id/article/$article_id";
	my $settings   = $storage->get_settings (loc $location) or die; # or throw

	if ( authorisation->permitted ( $user, write => $location ) ) {
		my $item = Articulate::Item->new(
			meta => {
				schema => {
					core => {
						updated => "$now" # ought to stringify
					}
				},
			},
			content => $content,
			location => $location,
		);

		validation->validate  ($item->meta, $item->content)     or die; # or throw

		$storage->set_meta    ($item) or die; # or throw
		$storage->set_content ($item) or die; # or throw

		interpreter->interpret ($item) or die; # or throw
		augmentation->augment  ($item) or die; # or throw

	  respond 'article', {
			article => {
				schema  => $item->meta->{schema},
				content => $item->content,
			},
		};
	}
	else {
		die '403';
	}
};

post '/login' => sub {
	my $user_id  = param('user_id');
	my $password = param('password');
	my $redirect = param('redirect') // '/';
	if ( defined $user_id ) {
		if ( authentication->login ($user_id, $password) ) {
			redirect $redirect; # do we accept ajax here, and do we do sth different?
		} # Can we handle all the exceptions with 403s?
		die '403';
	}
	else {
		# todo: see if we have email and try to identify a user and verify with that
		die '403';
	}
};



1;
