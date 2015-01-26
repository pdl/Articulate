use Test::More;
use Test::Exception;
use strict;
use warnings;

use          Articulate::Location;
use          Articulate::LocationSpecification;
my $class = 'Articulate::LocationSpecification';

my $test_suite = [
  {
    loc  => 'zone/public/article/hello-world',
    spec => 'zone/public/article/hello-world',
    expect => 1,
  },
  {
    loc  => 'zone/public/article/hello-world',
    spec => 'zone/*/article/hello-world',
    expect => 1,
  },
  {
    loc  => 'zone/public/article/hello-world',
    spec => '*/*/*/*',
    expect => 1,
  },
  {
    loc  => 'zone/public/article/hello-world',
    spec => 'zone/public',
    expect => 'ancestor',
  },
  {
    loc  => 'zone/public/article/hello-world',
    spec => 'zone/*',
    expect => 'ancestor',
  },
  {
    loc  => 'zone/public',
    spec => 'zone/public/article/hello-world',
    expect => 'descendant',
  },
  {
    loc  => 'zone/public',
    spec => 'zone/*/article/hello-world',
    expect => 'descendant',
  },
];


foreach my $case (@$test_suite) {
  my $why = $case->{why} // "'" . $case->{loc} . "' vs spec '" . $case->{spec} ."'";
  subtest $why => sub {
    my $loc  = loc $case->{loc};
    my $spec = locspec $case->{spec};
    my $expect = {
      map { $_=> 0 }
      qw (matches matches_ancestor_of matches_descendant_of)
    };
    if ($case->{expect} eq '1') { $expect->{$_} = 1 for keys %$expect }
    if ($case->{expect} eq 'ancestor')   { $expect->{$_} = 1 for qw(matches_ancestor_of) }
    if ($case->{expect} eq 'descendant') { $expect->{$_} = 1 for qw(matches_descendant_of) }

    foreach my $method ( keys %$expect ) {
      if ( $expect->{$method} ) {
        ok ( $spec->$method($loc), $method )
      }
      else {
        ok ( ! $spec->$method($loc), $method )
      }
    }
  }
}

done_testing();
