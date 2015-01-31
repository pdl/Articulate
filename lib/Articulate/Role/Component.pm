package Articulate::Role::Component;
use strict;
use warnings;
use Moo::Role;

# The following provide plugins which should be singletons within an application
# use Articulate::Storage          ();
# use Articulate::Authentication   ();
# use Articulate::Authorisation    ();
# use Articulate::Enrichment       ();
# use Articulate::Augmentation     ();
# use Articulate::Validation       ();
# use Articulate::Construction     ();
# use Articulate::FrameworkAdapter ();
use Articulate;
has app => (
  is      => 'rw',
);

sub storage        { shift->app->components->{'storage'}        }
sub authentication { shift->app->components->{'authentication'} }
sub authorisation  { shift->app->components->{'authorisation'}  }
sub enrichment     { shift->app->components->{'enrichment'}     }
sub augmentation   { shift->app->components->{'augmentation'}   }
sub validation     { shift->app->components->{'validation'}     }
sub construction   { shift->app->components->{'construction'}   }
sub framework      { shift->app->components->{'framework'}      }
sub serialisation  { shift->app->components->{'serialisation'}  }
sub service        { shift->app->components->{'service'}        }
sub navigation     { shift->app->components->{'navigation'}     }

1;
