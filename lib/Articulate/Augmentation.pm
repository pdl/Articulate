package Articulate::Augmentation;

use Moo;
use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

register augmentation => sub {
  __PACKAGE__->new(plugin_setting);
};

has augmentations =>
  is      => 'rw',
  default => sub { [] };

sub augment {
  my $self = shift;
  my $item = shift;
  foreach my $aug_class (@{ $self->augmentations }) {
    Module::Load::load $aug_class;
    $item = $aug_class->new->augment($item);
  }
  return $item;
}

register_plugin();

1;
