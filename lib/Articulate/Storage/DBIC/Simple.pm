package Articulate::Storage::DBIC::Simple;
use strict;
use warnings;

use Moo;
with 'Articulate::Role::Component';
use Articulate::Syntax;
use JSON;
use Scalar::Util qw(blessed);

=head1 NAME

Articulate::Content::Local - store your content locally

=cut

=head1 DESCRIPTION

This content storage interface works by placing content and metadata in folder structure.

For a given location, metadata is stored in C<meta.yml>, content in C<content.blob>.

Set C<content_base> in your config to specify where to place the content.

Caching is not implemented: get_content_cached simpy calls get_content.

=cut

=head1 METHODS

=cut

has schema => (
	is => 'rw',
	default => sub {
		return {
			class       => 'Articulate::Storage::DBIC::Simple::Schema',
			constructor => 'connect_and_deploy',
			args        => [
				'dbi:SQLite::memory:', '',''
			],
		}
	},
	coerce => sub {
		instantiate $_[0],
	},
);

sub dbic_find { # internal method
	my $self      = shift;
	my $location  = shift;
	my $dbic_item = $self->schema->resultset('Articulate::Item')->find( { location => "$location" } );
}

sub dbic_to_real { # internal method
	my $self      = shift;
	my $dbic_item = shift;
	return $self->construction->construct( {
		location => $dbic_item->location,
		meta     => from_json($dbic_item->meta),
		content  => $dbic_item->content,
	} );
}

sub real_to_dbic { # internal method
	my $self      = shift;
	my $item      = shift;
	my $dbic_item = $self->schema->resultset('Articulate::Item')->create( {
		location => '' . $item->location,
		content  => '' . $item->content,
		meta     => to_json ( $item->meta ),
	} );
}


=head3 get_item

	$storage->get_item( 'zone/public/article/hello-world' )

Retrieves the metadata for the content at that location.

=cut

sub get_item {
	my $self     = shift;
	my $location = shift->location;
	throw_error Internal => "Bad location $location" unless $self->navigation->valid_location( $location );
	my $dbic_item = $self->dbic_find ($location) or throw_error NotFound => "No item at $location";
	return $self->dbic_to_real( $dbic_item );
}

=head3 get_meta

	$storage->get_meta( 'zone/public/article/hello-world' )

Retrieves the metadata for the content at that location.

=cut

sub get_meta {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless $self->navigation->valid_location( $location );
	my $dbic_item = $self->dbic_find ($location) or throw_error NotFound => "No item at $location";
	return $self->dbic_to_real( $dbic_item )->meta;
}

=head3 set_meta

	$storage->set_meta( 'zone/public/article/hello-world', {...} )

Sets the metadata for the content at that location.

=cut

sub set_meta {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless $self->navigation->valid_location( $location );
	my $dbic_item = $self->dbic_find ($location) or throw_error NotFound => "No item at $location";
	$dbic_item->meta( to_json( $item->meta ) );
	$dbic_item->update;
	return $item;
}

=head3 patch_meta

	$storage->patch_meta( 'zone/public/article/hello-world', {...} )

Alters the metadata for the content at that location. Existing keys are retained.

CURRENTLY this affects top-level keys only, but a descent algorigthm is planned.

=cut

sub patch_meta {
	die 'not implemented'
}


=head3 get_settings

	$storage->get_settings('zone/public/article/hello-world')

Retrieves the settings for the content at that location.

=cut

sub get_settings {
	die 'not implemented'
}

=head3 set_settings

	$storage->set_settings('zone/public/article/hello-world', $amended_settings)

Retrieves the settings for the content at that location.

=cut

sub set_settings {
	die 'not implemented'
}

=head3 get_settings_complete

	$storage->get_settings_complete('zone/public/article/hello-world')

Retrieves the settings for the content at that location.

=cut

sub get_settings_complete {
	die 'not implemented'
}


=head3 get_content

	$storage->get_content('zone/public/article/hello-world')

Retrieves the content at that location.

=cut

sub get_content {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless $self->navigation->valid_location( $location );
	my $dbic_item = $self->dbic_find ($location) or throw_error NotFound => "No item at $location";
	return $self->dbic_to_real( $dbic_item )->content;
}

=head3 set_content

	$storage->set_content('zone/public/article/hello-world', $blob);

Places content at that location.

=cut

sub set_content {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless $self->navigation->valid_location( $location );
	my $dbic_item = $self->dbic_find ($location) or throw_error NotFound => "No item at $location";
	$dbic_item->content($item->content);
	$dbic_item->update;
	return $item;
}
=head3 create_item

	$storage->create_item('zone/public/article/hello-world', $meta, $blob);

Places meta and content at that location.

=cut

sub create_item {
	my $self = shift;
	my $item = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location ".$location unless $self->navigation->valid_location( $location );
	throw_error AlreadyExists => "Cannot create: item already exists at ".$location if $self->item_exists($location);
	my $dbic_item = $self->real_to_dbic ( $item );
	return $item;
}

=head3 item_exists

	if ($storage->item_exists( 'zone/public/article/hello-world')) {
		...
	}

Determines if the item has been created (only the C<meta.yml> is tested).

=cut


sub item_exists {
	my $self = shift;
	my $location = shift->location;
	throw_error Internal => "Bad location $location" unless $self->navigation->valid_location( $location );
	!! $self->dbic_find( $location );
}

=head3 list_items

	$storage->list_items ('/zone/public'); # 'hello-world', 'second-item' )

Returns a list of items in the.

=cut


sub list_items {
	die 'not implemented'
}

sub get_content_cached {
	my $self = shift;
	$self->get_content(@_);
}

sub get_meta_cached {
	my $self = shift;
	$self->get_meta(@_);
}

sub empty_all_content {
	my $self = shift;
	$self->schema->resultset('Articulate::Item')->delete();
}

sub delete_item {
	my $self     = shift;
	my $item     = shift;
	my $qm_location = $item->location;
	my $dbic_item = $self->schema->resultset('Articulate::Item')->search( { location => { like => "$qm_location" } } );
	$dbic_item->count or throw_error NotFound => 'Item does not exist at '.$item->location;
	$dbic_item->delete();
}

1;
