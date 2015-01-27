package Articulate::Serialisation::Asset;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';

=head1 NAME

Articulate::Serialisation::Asset - return your asset as a file

=head1 METHODS

=head3 serialise

If the meta schema.core.file is true, send the file as a schema.core.content_type.

=cut


use Dancer qw(:syntax);

sub serialise {
  my $self     = shift;
  my $response = shift;
  my $type     = $response->type;
  if ( $response->data->{$type} and ref $response->data->{$type} eq ref {} and $response->data->{$type}->{schema}->{core}->{file} ) {
    my $content_type = $response->data->{$type}->{schema}->{core}->{content_type} // $type ;
    content_type ( $content_type );
    my $content = $response->data->{$type}->{content} // '';
    send_file \$content, content_type => $content_type; # todo: permit sending raw blob?
    return 1;
  }
  return undef;
}

1;
