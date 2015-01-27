use Test::More;
use Articulate::Syntax qw(
  instantiate instantiate_array instantiate_selection
  loc         locspec
  dpath_get   dpath_set
  throw_error
  select_from
  is_single_key_hash
);
use strict;
use warnings;

use lib 't/lib';

isa_ok (instantiate('MadeUp::Class'), 'MadeUp::Class', 'instantiate works on class names' );

foreach my $foobar (
  instantiate({ class => 'MadeUp::Class', args => [{foo => 'bar'}] }),
  instantiate({ class => 'MadeUp::Class', args => {foo => 'bar'} }),
  instantiate({ 'MadeUp::Class' => {foo => 'bar'} }),
  ) {
  isa_ok ($foobar, 'MadeUp::Class', 'can use hashref and set class' );
  is ($foobar->foo, 'bar', 'can use hashref and pass bar' );
}

is ( instantiate( {
  class => 'MadeUp::Class::WeirdConstructor',
  constructor => 'makeme',
  args => { foo => 'bar' },
} )->foo, 'bar', 'can use hashref and set constructor' );

instantiate({ class => 'MadeUp::Class::Singleton', args => [{foo => 'bar'}] });

is instantiate('MadeUp::Class::Singleton')->foo, 'bar';

is instantiate({ class => 'MadeUp::Class::Singleton' })->foo, 'bar';


my $altered = MadeUp::Class->new;
$altered->foo('bor');
isa_ok (instantiate($altered), 'MadeUp::Class', 'instantiate works on existing objects' );
is (instantiate($altered)->foo, 'bor', 'instantiate does not try to recreate existing objects' );

my $structure = { foo => {bar => 2}, baz => [ 3, 4 ] };

is ( dpath_get( $structure, '/foo/bar' ), 2);
is ( dpath_get( $structure, '/baz/*[0]' ), 3);

is ( dpath_set( $structure, '/baz/*', 5 ), 5);
is ( $structure->{baz}->[0], 5);

is ( is_single_key_hash( undef ), 0 );
is ( is_single_key_hash( [ foo => 123 ] ), 0 );
is ( is_single_key_hash( { foo => 123 } ), 1 );
is ( is_single_key_hash( { foo => 123, bar => 123} ), 0 );
is ( is_single_key_hash( { foo => 123 }, 'foo' ), 1 );
is ( is_single_key_hash( { bar => 123 }, 'foo' ), 0 );
is ( is_single_key_hash( { foo => 123, bar => 123}, 'foo', ), 0 );

done_testing;
