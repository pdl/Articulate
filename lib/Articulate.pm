package Articulate;
use Dancer ':syntax';
use Articulate::Storage;
use Articulate::Interpreter;
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
	my $meta       = $storage->get_meta_cached     ($location) or die; # or throw
	my $settings   = $storage->get_settings        ($location) or die; # or throw
	my $content    = $storage->get_content_cached  ($location) or die; # or throw

	my $interpreted_content = interpreter->interpret ($meta, $content) or die; # or throw

	if ( has_read_permissions ($user, $settings) ) {
	  respond article => {
			article => {
				schema  => $meta->{schema},
				content => $interpreted_content,
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
	my $settings   = $storage->get_settings ($location) or die; # or throw

	if ( has_write_permissions ($user, $settings) ) {
		my $meta = {
			schema => {
				core => {
					updated => "$now" # ought to stringify
				}
			}
		};

		$storage->set_meta    ($location, $meta)    or die; # or throw
		$storage->set_content ($location, $content) or die; # or throw

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

# TODO: Farm these out to a SecurityModel package
use Digest::SHA;

post '/login' => sub {
	my $user_id  = param('user_id');
	my $password = param('password');
	my $redirect = param('redirect') // '/';
	if ( defined $user_id ) {
		if ( login_as ($user_id, $password) ) {
			redirect $redirect; # do we accept ajax here, and do we do sth different?
		} # Can we handle all the exceptions with 403s?
		die '403';
	}
	else {
		# todo: see if we have email and try to identify a user and verify with that
		die '403';
	}
};

sub login_as {
	my ($user_id, $plaintext_password) = @_;
	if ( verify_password ( $user_id, $plaintext_password ) ) {
		session user_id => $user_id;
		return $user_id;
	}
	# if we ever need to know if the user does not exist, now is the time to ask,
	# but we do not externally expose the difference between
	# "user not found" and "password doesn't match"
	return undef;
}

sub password_salt_and_hash {
	return Digest::SHA::sha512_base64 (
		shift . (
			config->{password_salt} # don't allow the admin not to set a salt
			|| "If you haven't already, try powdered vegetable bouillon"
		)
	);
}

sub verify_password {
	my ($user_id, $plaintext_password) = @_;
	my $real_encrypted_password = get_meta ("/users/$user_id")->{encrypted_password};
	return undef unless $real_encrypted_password;
	return ( $real_encrypted_password eq password_salt_and_hash ($plaintext_password) );
}

# note: currently this implicitly creates a user. Should set/patch create new content, or just edit it?
# maybe a create verb - but is is this going to be compatible with kvp stores? How will this work when you have content and meta and settings all to be created?
sub set_password {
	my ($user_id, $plaintext_password) = @_;
	return undef unless $plaintext_password; # as empty passwords will only cause trouble.
	patch_meta ( "/user/$user_id", {
		encrypted_password => password_salt_and_hash ($plaintext_password),
	} ) and verify_password(@_);
}


1;
