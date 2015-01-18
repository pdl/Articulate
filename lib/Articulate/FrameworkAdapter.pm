package Articulate::FrameworkAdapter;

use Moo;
with 'MooX::Singleton';
use Articulate::Syntax qw(instantiate);
use Dancer::Plugin;

# Currently, only Dancer1 is supported.

register framework => sub {
  __PACKAGE__->instance(plugin_setting)->provider;
};

has provider => (
  is      => 'rw',
  default => sub { 'Articulate::FrameworkAdapter::Dancer1' },
  coerce  => sub { instantiate(@_) },
);

register_plugin();

1;
