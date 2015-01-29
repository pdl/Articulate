package Articulate::Syntax::Routes;
use strict;
use warnings;
use Dancer qw(:syntax);

use Exporter::Declare;
default_exports qw(
  any get post patch del put options
  request upload uploads captures param params splat
  config var session template
  redirect forward halt pass send_error status
); # the first line will stay, everything else will find its way into framework

1;
