package Articulate::FrameworkAdapter::Dancer2;
use strict;
use warnings;

use Moo;
with 'MooX::Singleton';
with 'Articulate::Role::Component';
require Dancer2;

has appname =>
  is => 'rw',
  default => sub { undef };

has d2app =>
  is      => 'rw',
  lazy    => 1,
  default => sub {
    my $self = shift;
    Dancer2->import ( appname => $self->appname );
    my @apps = grep { $_->name eq $self->appname } @{ Dancer2::runner()->apps };
    return $apps[0];
  }
;
sub user_id {
  my $self = shift;
  Dancer2::Core::DSL::session( $self->d2app, user_id => @_);
}

sub appdir {
  my $self = shift;
  Dancer2::config()->{appdir};
}

sub session {
  my $self = shift;
  Dancer2::Core::DSL::session( $self->d2app, @_);
}

sub template_process {
  my $self = shift;
  $self->d2app->template_engine->process( @_ );
}

sub declare_route {
  my ($self, $verb, $path, $code) = @_;
  $self->d2app;
  if ($verb =~ m/^(get|put|post|patch|del|any|options)$/) {#'Dancer2::Core::DSL::'.lc $1;/ge) {
    {
      no strict 'refs';
      $self->d2app->add_route( method => $verb, regexp => $path, code => $code );
    }
  }
  else {
    die ('Unknown HTTP verb '.$verb);
  }
}

1;
