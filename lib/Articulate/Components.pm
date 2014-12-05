package Articulate::Components;

use Moo;
use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

register components => sub {
  __PACKAGE__->new(plugin_setting);
};

has all_components =>
  is      => 'rw',
  default => sub { [] };

sub process {
  my $self = shift;
  my $meta = shift;
  my $content = shift;
  foreach my $component_class (@{ $self->all_components }) {
    ($meta, $content) = $component_class->new->process($meta, $content);
  }
  return ($meta, $content);
}

register_plugin();

1;
