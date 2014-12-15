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
  my $item = shift;
  foreach my $component_class (@{ $self->all_components }) {
    $item = $component_class->new->process($item);
  }
  return $item;
}

register_plugin();

1;
