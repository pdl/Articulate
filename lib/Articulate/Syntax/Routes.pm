package Articulate::Syntax::Routes;
use strict;
use warnings;
use Dancer qw(:syntax);
use Exporter::Declare;
use Articulate::Service;
default_exports qw(
  any get post patch del put options
  request upload uploads captures param params splat
  config var session template
  redirect forward halt pass send_error status
); # the first line will stay, everything else will find its way into framework

no warnings 'redefine';

sub on_enable(&) {
  my $code = shift;
  my ($pkg) = caller(1);
  my $routes = "${pkg}::__routes";
  {
    no strict 'refs';
    $$routes //= [];
    push @$$routes, $code;
  }
}

sub get {
  my $path = shift;
  my $code  = pop;
  on_enable {
    my $service = shift;
    $service->framework->declare_route( get => $path => sub { perform_request( $code, [ $service, request ] ) } );
  }
}


sub post {
  my $path = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    $service->framework->declare_route( post => $path => sub { perform_request( $code, [ $service, request ] ) } );
  }
}

sub patch {
  my $path = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    $service->framework->declare_route( patch => $path => sub { perform_request( $code, [ $service, request ] ) } );
  }
}

sub del {
  my $path = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    $service->framework->declare_route( del => $path => sub { perform_request( $code, [ $service, request ] ) } );
  }
}

sub put {
  my $path = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    $service->framework->declare_route( put => $path => sub { perform_request( $code, [ $service, request ] ) } );
  }
}

sub perform_request {
  #die to_yaml [@_];
  $_[0]->(@{ $_[1] });
}

1;
