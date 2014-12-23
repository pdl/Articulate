package Articulate::Augmentation;

use Moo;
with 'MooX::Singleton';
use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

=head1 NAME

Articulate::Augmentaton - add bells and whistles to your response

=head1 DESCRIPTION

  use Articulate::Augmentation;
  $response = augmentation->aughment($response);

This will pass the response to a series of augmentation objects, each of which has the opportunity to alter the response according to their own rules, for instance, to retrieve additional related content (e.g. article comments).

Note: the response passed in is not cloned so this will typically mutate the response.

=head1 FUNCTION

=head3 augmentation

This is a functional constructor: it returns an Articulate::Augmentation object.

=cut

register augmentation => sub {
  __PACKAGE__->instance(plugin_setting);
};

=head1 ATTRIBUTES

=head3 augmentations

An array of the augmentation classes which will be used.

=cut

has augmentations =>
  is      => 'rw',
  default => sub { [] };

=head1 METHODS

=head3 augment

Passes the response object to a series of augmentation objects, and returns the response after each has done their bit.

=cut

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
