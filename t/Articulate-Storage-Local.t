use Test::More;
use strict;
use warnings;

# the order is important
use Articulate::TestEnv;
use Scalar::Util qw(blessed);

my $class = 'Articulate::Storage::Local';

use_ok $class;

my $storage = $class->new();

isa_ok ( $storage, $class );

foreach my $method ( qw[
  create_item
  delete_item
  get_meta
  get_meta_cached
  set_meta
  get_content
  get_content_cached
  set_content
  get_settings
  set_settings
  list_items
  item_exists
  empty_all_content
] ) {
  ok ( $storage->can($method), "$method is a required method of all storage classes" );
  #can_ok ( $storage, $method, "$method is a required method of all storage classes" );
}

done_testing();
