package Articulate::Storage;
use strict;
use warnings;

use Dancer::Plugin;
use Moo;
extends 'Articulate::Storage::Local'; # let's cheat
with 'Articulate::Role::Component';
#use Articulate::Syntax qw(instantiate);

=head1 NAME

Articulate::Storage - store and retrieve your content

=head1 DESCRIPTION

This provides a single function, storage, which returns the storage object to which responsibility has been delegated for persistant storage and retrieval of content.

By default, this will return an instance of C<Articulate::Storage::Local>.

=cut

1;
