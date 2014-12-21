package Articulate;
use Dancer ':syntax';
use Articulate::Service;
use Articulate::Error;
our $VERSION = '0.1';
use DateTime;

sub now {
	DateTime->now;
}

my $service = articulate_service;

sub respond {
	my ($response_type, $response_data);
	if ( ref $_[0] ) {
		$response_type = $_[0]->type;
		$response_data = $_[0]->data;
		status $_[0]->http_code // 500;
	}
	else {
		my ($response_type, $response_data) = @_;
		if ( $response_type eq 'error' ) {
			try {
				status $response_data->{error}->http_code // 500;
			}
			catch {
				status 500;
			}
		}
	}
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
				#user_id => session('user_id'),
			},
		};
	}
}

get '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	respond $service->process_request(
		read => {
			location => "zone/$zone_id/article/$article_id",
		}
	);
};

post '/zone/:zone_id/article/:article_id' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $content    = param ('content');
	respond $service->process_request(
		create => {
			location =>"zone/$zone_id/article/$article_id",
			content  => $content,
		}
	);
};

post '/zone/:zone_id/article/:article_id/edit' => sub {
	my $zone_id    = param ('zone_id');
	my $article_id = param ('article_id');
	my $content    = param ('content');
	respond $service->process_request(
		edit => {
			location =>"zone/$zone_id/article/$article_id",
			content  => $content,
		}
	);
};

post '/login' => sub {
	my $user_id  = param('user_id');
	my $password = param('password');
	my $redirect = param('redirect') // '/';
	if ( defined $user_id ) {
		if ( $service->authentication->login ($user_id, $password) ) {
			redirect $redirect; # do we accept ajax here, and do we do sth different?
		} # Can we handle all the exceptions with 403s?
		throw_error 'Forbidden';
	}
	else {
		# todo: see if we have email and try to identify a user and verify with that
		throw_error 'Forbidden';
	}
};



1;
