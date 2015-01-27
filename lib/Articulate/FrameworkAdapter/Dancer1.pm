package Articulate::FrameworkAdapter::Dancer1;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';
use Dancer qw(:syntax !after !before !session);

sub user_id {
  my $self = shift;
  session ('user_id', @_);
}

sub appdir {
  my $self = shift;
  config->{appdir};
}

sub session {
  Dancer::session(@_);
}


1;
