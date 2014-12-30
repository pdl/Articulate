use Test::More;
use Articulate::Syntax qw(instantiate);
use strict;
use warnings;

use lib 't/lib';

isa_ok (instantiate('MadeUp::Class'), 'MadeUp::Class', 'instantiate works on class names' );

foreach my $foobar (
  instantiate({ class => 'MadeUp::Class', args => [{foo => 'bar'}] }),
  instantiate({ class => 'MadeUp::Class', args => {foo => 'bar'} }),
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

done_testing;
