use Test::More;
use Test::Exception;
use strict;
use warnings;

use Articulate::Item ();

use Articulate::Flow::ContentType;
my $class = 'Articulate::Flow::ContentType';

sub item {
  Articulate::Item->new( { meta => shift } );
}
{

  package Dummy::Provider;
  use Moo;
  with 'Articulate::Role::Flow';
  has good   => is => 'rw';
  has reason => is => 'rw';

  sub process_method {
    my $self = shift;
    Test::More::ok( $self->good, $self->reason );
  }
}

sub then_pass {
  Dummy::Provider->new( { good => 1, reason => $_[0] } );
}

sub then_fail {
  Dummy::Provider->new( { good => 0, reason => $_[0] } );
}

my $test_suite = [
  {
    item => { schema => { core => { content_type => 'text/markdown' } } },
    args => {
      where => {
        'text/markdown' => then_pass('should succeed'),
      },
      otherwise => then_fail('should have already succeeded'),
    }
  },
  {
    item => { schema => {} },
    args => {
      where => {
        'text/markdown' => then_fail('undefined does not match'),
      },
      otherwise => then_pass,
    }
  },
  {
    item => { schema => { core => { content_type => 'text/markdown' } } },
    args => {
      where => {
        'application/xml' => then_fail('does not match'),

        'text/markdown' => then_pass('exit at first oppotunity'),
      },
      otherwise => then_fail('should have already succeeded'),
    }
  },
  {
    item => { schema => { core => { content_type => 'text/markdown' } } },
    args => {
      where => {
        'application/xml' => then_fail('does not match'),
      },
      otherwise => then_pass('no where matches'),
    }
  },
];

foreach my $case (@$test_suite) {
  my $why = $case->{why} // '';
  subtest $why => sub {
    my $switcher = $class->new( $case->{args} );
    $switcher->augment( item $case->{item} );
  };
}

done_testing();
