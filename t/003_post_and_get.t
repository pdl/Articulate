use Test::More;
use strict;
use warnings;

# the order is important
use Articulate::TestEnv;
use Articulate;
use Dancer::Test;

my $random_string = rand(0xffff);

my $post_response = dancer_response (
	POST => '/zone/public/create', {
		body => {
			article_id => 'hello-world',
			content    => $random_string
		}
	}
);

is ( $post_response->status, 200,
	'response status is 200 for POST /zone/public/create'
);

response_status_is [ GET =>  '/zone/public/article/hello-world' ], 200,
	'response status is 200 for GET  /zone/public/article/hello-world';

done_testing();
