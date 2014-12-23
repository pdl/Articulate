package Articulate::Validation;

use Moo;
with 'MooX::Singleton';
use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

=head1 NAME

Articulate::Validation - ensure content is valid before accepting it.

=head1 DESCRIPTION

  use Articulate::Validation;
  validation->validate($meta, $content) or throw_error;

Validators should return a true argument if either a) The item is valid, or b) The validator has no opinion on the item.

=head1 FUNCTION

=head3 validation

This is a functional constructor: it returns an Articulate::Validation object.

=cut

register validation => sub {
  __PACKAGE__->instance(plugin_setting);
};

=head1 METHODS

=head3 validate

Iterates through the validators. Returns false if any has a false result. Returns true otherwise.

=cut

=head1 ATTTRIBUTES

=head3 validators

An arrayref of the classes which provide a validate function, in the order in which they will be asked to validate items.

=cut

has validators =>
  is      => 'rw',
  default => sub { [] };

sub validate {
  my $self    = shift;
  my $meta    = shift;
  my $content = shift;
  foreach my $validator_class (@{ $self->validators }) {
    Module::Load::load $validator_class;
    my $result = $validator_class->new->validate($meta, $content);
    return $result unless $result;
  }
  return 1;
}

register_plugin();

1;
