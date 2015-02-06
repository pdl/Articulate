package Articulate::Storage::DBIC::Simple::Schema;

use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_namespaces();

sub connect_and_deploy {
  my $package = shift;
  my $self = $package->connect(@_);
  $self->deploy();
  return $self;
}

1;
