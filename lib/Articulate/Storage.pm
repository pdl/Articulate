package Articulate::Storage;

use Dancer qw(:syntax !after !before);
use Dancer::Plugin;
use Moo;
use Articulate::Syntax qw(instantiate);

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
  instantiate (plugin_setting->{storage_class} // 'Articulate::Storage::Local');
};

register_plugin();

1;
