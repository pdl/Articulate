package Articulate::Storage;

use Dancer ':syntax';
use Dancer::Plugin;
use Module::Load ();

=head1 NAME

Articulate::Storage - store and retrieve your content

=head1 DESCRIPTION

This provides a single function, storage, which returns the storage object to which responsibility has been delegated for persistant storage and retrieval of content.

By default, this will return an instance of C<Articulate::Storage::Local>.

=head1 FUNCTIONS

=head1 storage

Returns an instance of the storage class defined in your C<config.yml>.

=cut

register storage => sub {
  my $storage_class = plugin_setting->{storage_class} // 'Articulate::Storage::Local';
  Module::Load::load $storage_class;
  $storage_class->new(@_);
};

register_plugin();

1;
