use Test::More;
use Test::Exception;
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

my $new_item = sub{
  Articulate::Item->new( { content => "Hello, World!", location => 'zone/public/article/hello-world' } )
};

my $item = $new_item->();

ok ( !$storage->item_exists( $item->location ), 'item_exists returns false when the item does not exist' );

foreach my $method ( qw[
  delete_item
  get_meta
  get_meta_cached
  set_meta
  get_content
  get_content_cached
  set_content
] ) {
  throws_ok (sub { $storage->$method( $new_item->() ) }, 'Articulate::Error', "Calling $method when item does not exist should die");
}


isa_ok ( $storage->create_item($item), 'Articulate::Item', 'create_item returns the item' );
ok ( $storage->item_exists( $item->location ), 'create_item results in the item existing' );
isa_ok ( $storage->get_item($item->location), 'Articulate::Item', 'get_item returns an item' );
is ( $storage->get_item($item->location)->content, "Hello, World!", 'get_item returns an item with the same content' );
is ( $storage->get_content($item->location), "Hello, World!", 'get_content returns the same content' );
$storage->delete_item($item->location);
ok ( !$storage->item_exists( $item->location ), 'delete_item deletes the item' );

isa_ok ( $storage->create_item($item), 'Articulate::Item', 'create_item recreates the item' );
ok ( $storage->item_exists( $item->location ), 'create_item results in the item existing (again)' );
throws_ok ( sub { $storage->create_item($new_item->()) }, 'Articulate::Error::AlreadyExists', "Calling create_item when item already exists should die");
$storage->empty_all_content;
ok ( !$storage->item_exists( $item->location ), 'empty_all_content deletes the item' );


done_testing();
