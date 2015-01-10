package Articulate::FrameworkAdapter;

use Moo;
with 'MooX::Singleton';
use Dancer qw(:syntax !after !before);
use Dancer::Plugin;

# Currently, only Dancer1 is supported.
# Later, we will do delegation. For now, we collect the important communication with the framework in anticipation.

register framework => sub {
  __PACKAGE__->instance(plugin_setting);
};


sub user {
  my $self = shift;
  session ('user_id', @_);
}

register_plugin();

1;
