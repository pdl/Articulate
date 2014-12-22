package Articulate::Serialisation;

use Moo;
with 'MooX::Singleton';
use Dancer qw(:syntax);
use Dancer::Plugin;
use Module::Load ();

register serialisation => sub {
  __PACKAGE__->instance( plugin_setting() );
};

has serialisers => (
  is      => 'rw',
  default => sub{ [] },
);

sub serialise {
  my $self     = shift;
  my $response = shift;
  my $text;
  foreach my $serialiser_class (@{ $self->serialisers }) {
    Module::Load::load ($serialiser_class);
    return $text if defined ( $text = $serialiser_class->new->serialise($response) );
  }
  return undef;
}

register_plugin;

1;
