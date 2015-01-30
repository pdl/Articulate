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
  my $self = shift;
  Dancer::session(@_);
}

sub declare_route {
  my ($self, $verb, $path, $code) = @_;
  if ($verb =~ s/^(get|put|post|patch|del|any|options)$/'Dancer::'.lc $1;/ge) {
    {
      no strict 'refs';
      &$verb($path, $code);
    }
  }
  else {
    die ('Unknown HTTP verb '.$verb);
  }
}

1;
