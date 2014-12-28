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
}

my $item = Articulate::Item->new( { content => "Hello, World!", location => 'zone/public/article/hello-world' } );
ok ( !$storage->item_exists( $item->location ), 'item_exists returns false when the item does not exist' );
isa_ok ( $storage->create_item($item), 'Articulate::Item', 'create_item returns the item' );
ok ( $storage->item_exists( $item->location ), 'create_item results in the item existing' );
isa_ok ( $storage->get_item($item->location), 'Articulate::Item', 'get_item returns an item' );
is ( $storage->get_item($item->location)->content, "Hello, World!", 'get_item returns an item with the same content' );
is ( $storage->get_content($item->location), "Hello, World!", 'get_content returns the same content' );
$storage->delete_item($item->location);
ok ( !$storage->item_exists( $item->location ), 'delete_item deletes the item' );

done_testing();
