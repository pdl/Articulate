package Articulate::Construction;
use strict;
use warnings;

use Moo;
use Articulate::Syntax qw(instantiate_array);
use Articulate::Item;
with 'MooX::Singleton';

use Dancer::Plugin;
use YAML;
register construction => sub {
  __PACKAGE__->instance(plugin_setting);
};

has constructors => (
  is      => 'rw',
  default => sub { [] },
  coerce  => sub { instantiate_array(@_) }
);

sub construct {
  my $self = shift;
  my $args = shift;
  my $constructed;
  foreach my $constructor ( @{ $self->constructors } ) {
    $constructed = $constructor->construct($args);
    return $constructed if defined $constructed;
  }
  return Articulate::Item->new($args);
}

register_plugin;

1;
