package Articulate::File;
use strict;
use warnings;
use Moo;
use overload '""' => sub { shift->_to_string };

=head1 NAME

Articulate::File - represent a file

=cut

=head1 METHODS

=cut

has content_type => ( is => 'rw', );
has headers      => ( is => 'rw', );
has filename     => ( is => 'rw', );
has io           => ( is => 'rw', );

sub _to_string {
  my $self = shift;
  local $/;
  join '', $self->io->getlines;
}

1;
