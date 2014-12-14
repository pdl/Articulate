package Articulate::Location;
use Moo;
use Scalar::Util qw(blessed);
use overload  '""' => \&to_file_path, '@{}' => sub{ shift->path };
use Dancer::Plugin ();

Dancer::Plugin::register loc => sub {
  if ( 1 == scalar @_ ) {
    if ( blessed $_[0] and $_[0]->isa('Articulate::Location') ) {
      return $_[0];
    }
    elsif ( ref $_[0] eq 'ARRAY' ) {
      return __PACKAGE__->new({ path => $_[0] });
    }
    elsif ( !defined $_[0] ) {
      return __PACKAGE__->new;
    }
    elsif ( !ref $_[0] ) {
      return __PACKAGE__->new({ path => [ split /\//, $_[0] ] });
    }
    elsif ( ref $_[0] eq 'HASH' ) {
      return __PACKAGE__->new($_[0]);
    }
  }
};

has path => (
  is      => 'rw',
  default => sub { []; },
);

sub location {
  return shift;
}
sub to_file_path {
  return join '/', @{ $_[0]->path }
};

Dancer::Plugin::register_plugin;

1;
