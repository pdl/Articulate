package Articulate::Interpreter;

use Dancer qw(:syntax !after !before);
use Dancer::Plugin;
use Module::Load ();
use Moo;
use Articulate::Syntax qw(instantiate_array);

register interpreter => sub {
  __PACKAGE__->new(plugin_setting);
};

has default =>
  is => 'rw';

has interpreters =>
  is      => 'rw',
  default => sub { [] },
  coerce  => sub { instantiate_array(@_) };

sub interpret {
  my $self = shift;
  my $item = shift;
  foreach my $interpreter ( @{ $self->interpreters } ) {
    $interpreter->interpret( $item ); # todo: determine the content type and pick the right intepreter
  }
}

register_plugin();

1;
