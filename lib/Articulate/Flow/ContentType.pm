package Articulate::Flow::ContentType;
use Moo;
use Articulate::Syntax qw (instantiate instantiate_array);

=head1 NAME

Articulate::Flow::ContentType - add a creation date to the meta

=head1 CONFIGURATION

  - class: Articulate::Flow::ContentType
    args:
      where:
        'text/markdown':
          - Articulate::Enrichment::Markdown

=head1 METHODS

=head3 process_method

Sets the creation date (C<meta.schema.core.dateCreated>) to the current time, unless it already has a defined value.

=cut

has where => (
  is      => 'rw',
  default => sub{ {} },
  coerce  => sub{
    my $orig = shift // {};
    foreach my $type ( keys %$orig ){
      $orig->{$type} = instantiate_array ( $orig->{$type} );
    }
    return $orig;
  },
);

has otherwise => (
  is      => 'rw',
  default => sub{ {} },
  coerce  => sub{
    #instantiate_array @_
  },
);

sub enrich {
  my $self = shift;
  $self->process_method( enrich => @_)
}

sub augment {
  my $self = shift;
  $self->process_method( augment => @_)
}

sub _delegate {
  my ( $self, $method, $providers, $args ) = @_;
  foreach my $provider ( @$providers ) {
    my $result = $provider->$method(@$args);
    return $result unless defined $result;
  }
  return $args->[0];
}

sub process_method {
  my $self    = shift;
  my $method  = shift;
  my $item    = shift;
  my $content_type = $item->meta->{schema}->{core}->{content_type};
  if (defined $content_type) {
    foreach my $type ( keys %{$self->where} ) {
      if ($type eq $content_type) {
        return $self->_delegate( $method => $self->where->{$type}, [$item, @_] );
      }
    }
  }
  if (defined $self->otherwise) {
    return $self->_delegate( $method => $self->otherwise, [$item, @_] );
  }
  return $item;
}

1;
