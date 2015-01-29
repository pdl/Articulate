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
  my $route = shift;
  my $code  = pop;
  on_enable {
    my $service = shift;
    Dancer::get $route => sub { perform_request( $code, [ $service, request ] ) };
  }
}


sub post {
  my $route = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    Dancer::post $route => sub { perform_request( $code, [ $service, request ] ) };
  }
}

sub patch {
  my $route = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    Dancer::patch $route => sub { perform_request( $code, [ $service, request ] ) };
  }
}

sub del {
  my $route = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    Dancer::del $route => sub { perform_request( $code, [ $service, request ] ) };
  }
}

sub put {
  my $route = shift;
  my $code  = shift;
  on_enable {
    my $service = shift;
    Dancer::put $route => sub { perform_request( $code, [ $service, request ] ) };
  }
}

sub perform_request {
  #die to_yaml [@_];
  $_[0]->(@{ $_[1] });
}

1;
