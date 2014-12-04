package Articulate::Storage;

use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

register storage => sub {
  my $storage_class = plugin_setting->{storage_class} // 'Articulate::Storage::Local';
  Module::Load::load $storage_class;
  $storage_class->new(@_);
};

register_plugin();

1;
