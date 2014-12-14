package Articulate::Item;
use Moo;
use Dancer ':syntax';
use Dancer::Plugin;

has location => (
  is      => 'rw',
  default => sub { Articulate::Location->new; },
  coerce  => sub { Articulate::Location::loc(shift); }
);

has meta => (
  is      => 'rw',
  default => sub { {} },
);

has content => (
  is      => 'rw',
  default => sub { undef },
);

1;
