package Articulate::Interpreter;

use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();
use Moo;

register interpreter => sub {
  __PACKAGE__->new(plugin_setting);
};

has default =>
  is => 'rw';

has file_types =>
  is      => 'rw',
  default => sub { {} };

sub interpret {
  my $self = shift;
  my $meta = shift;
  my $content = shift;
  my $interpreter_class = $self->file_types->{ $self->default };
  Module::Load::load $interpreter_class;
  $interpreter_class->new->interpret( $meta, $content ); # todo: determine the content type and pick the right intepreter
}

register_plugin();

1;
