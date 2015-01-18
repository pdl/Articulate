package Articulate::FrameworkAdapter::Dancer1;

use Moo;
with 'MooX::Singleton';
use Dancer qw(:syntax !after !before);

sub user_id {
  my $self = shift;
  session ('user_id', @_);
}

1;
