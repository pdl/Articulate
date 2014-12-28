package Articulate::Storage::Local;
use Articulate::Storage::Common;
use Dancer ':syntax';
use Dancer::Plugin;
use Moo;
with 'MooX::Singleton';
use File::Path;
use IO::All;
use YAML;
use Articulate::Error;


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

my $content_base;

sub content_base { # todo: make this an attribute
	my $self = shift;
	$content_base	//=
		config->{content_base}
		// (
			config->{appdir}
			// throw_error ( Internal => 'appdir not set')
		).'/content/';
	unless (-d $content_base) {
		File::Path::make_path $content_base;
		throw_error (Internal => 'Could not initialise content base') unless (-d $content_base);
	}
	return $content_base;
}

sub ensure_exists { # internal method
	my $self = shift;
	my $true_location_full = shift // return undef;
	my $true_location = $true_location_full =~ s~[^/]+\.[^/]+$~~r;
	unless (-d $true_location) {
		File::Path::make_path $true_location;
	}
	return -d $true_location ? $true_location_full : throw_error ('Internal' => 'Could not create directory for location');
}

sub true_location {
	my $self = shift;
	return $self->content_base . shift;
}


=head3 get_item

$storage->get_item( 'zone/public/article/hello-world' )

Retrieves the metadata for the content at that location.

=cut

sub get_item {
	my $self     = shift;
	my $location = shift->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $item = Articulate::Item->new( { location => $location } );
	$item->meta    ( $self->get_meta($item) );
	$item->content ( $self->get_content($item) );
	return $item;
}

=head3 get_meta

	$storage->get_meta( 'zone/public/article/hello-world' )

Retrieves the metadata for the content at that location.

=cut

sub get_meta {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $fn = $self->true_location ( $location . '/meta.yml' );
	return YAML::LoadFile($fn) if -e $fn;
	return {};
}

=head3 set_meta

	$storage->set_meta( 'zone/public/article/hello-world', {...} )

Sets the metadata for the content at that location.

=cut

sub set_meta {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location ".$location unless good_location $location;
	my $fn = $self->ensure_exists( $self->true_location( $location . '/meta.yml' ) );
	YAML::DumpFile($fn, $item->meta);
	return $item;
}

=head3 patch_meta

	$storage->patch_meta( 'zone/public/article/hello-world', {...} )

Alters the metadata for the content at that location. Existing keys are retained.

CURRENTLY this affects top-level keys only, but a descent algorigthm is planned.

=cut

sub patch_meta {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location ".$location unless good_location $location;
	my $fn = $self->ensure_exists( $self->true_location( $location . '/meta.yml') );
	my $old_data = {};
	$old_data = YAML::LoadFile($fn) if -e $fn;
	return YAML::DumpFile($fn, merge_settings($old_data, $item->meta));
}


=head3 get_settings

	$storage->get_settings('zone/public/article/hello-world')

Retrieves the settings for the content at that location.

=cut

sub get_settings {
	my $self     = shift;
	my $item     = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $fn = $self->true_location ( $location . '/settings.yml' );
	return YAML::LoadFile($fn) if -e $fn;
	return {};
}

=head3 set_settings

	$storage->set_settings('zone/public/article/hello-world', $amended_settings)

Retrieves the settings for the content at that location.

=cut

sub set_settings {
	my $self     = shift;
	my $location = shift->location;
	my $settings = shift;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $fn = $self->ensure_exists( $self->true_location( $location . '/settings.yml' ) );
	YAML::DumpFile($fn, $settings);
	return $settings;
}

=head3 get_settings_complete

	$storage->get_settings_complete('zone/public/article/hello-world')

Retrieves the settings for the content at that location.

=cut

sub get_settings_complete {
	my $self     = shift;
	my $location = shift->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my @paths = split /\//, $location;
	my $current_path = $self->true_location( '' ).'/';
	my $settings = {};
	foreach my $p (@paths) {
		my $fn = $current_path . 'settings.yml';
		my $lvl_settings = {};
		$lvl_settings =	YAML::LoadFile($fn) if -e $fn;
		$settings = merge_settings ($settings, $lvl_settings)
	}
	return $settings;
}


=head3 get_content

	$storage->get_content('zone/public/article/hello-world')

Retrieves the content at that location.

=cut

sub get_content {
	my $self = shift;
	my $location = shift->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $fn = $self->true_location( $location . '/content.blob' );
	open my $fh, '<', $fn or throw_error Internal => "Cannot open file $fn to read";
	return '' . (join '', <$fh>);
}

=head3 set_content

	$storage->set_content('zone/public/article/hello-world', $blob);

Places content at that location.

=cut


sub set_content {
	my $self = shift;
	my $item = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $fn = $self->ensure_exists( $self->true_location( $location . '/content.blob' ) );
	open my $fh, '>', $fn or throw_error Internal => "Cannot open file $fn to write";
	print $fh $item->content;
	close $fh;
	return $location;
}

=head3 create_item

	$storage->create_item('zone/public/article/hello-world', $meta, $blob);

Places meta and content at that location.

=cut


sub create_item {
	my $self = shift;
	my $item = shift;
	my $location = $item->location;
	throw_error Internal => "Bad location ".$location unless good_location $location;
	{
		my $fn = $self->ensure_exists( $self->true_location( $location . '/content.blob' ) );
		open my $fh, '>', $fn or throw_error Internal => "Cannot open file $fn to write";
		print $fh $item->content;
		close $fh;
	}
	{
		my $fn = $self->ensure_exists( $self->true_location( $location . '/meta.yml' ) );
		$self->set_meta($item);
	}
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
	throw_error Internal => "Bad location $location" unless good_location $location;
	return -e $self->true_location( $location . '/meta.yml' );
}

=head3 list_items

	$storage->list_items ('/zone/public'); # 'hello-world', 'second-item' )

Returns a list of items in the.

=cut


sub list_items {
	my $self = shift;
	my $location = shift->location;
	throw_error Internal => "Bad location $location" unless good_location $location;
	my $true_location = $self->true_location( $location );
	my @contents;
	return @contents unless -d $true_location;
	opendir (my $dh, $true_location) or throw_error NotFound => ('Could not open '.$true_location);
	while (readdir $dh) {
		my $child_dn = $true_location.'/'.$_;
		next unless -d $child_dn;
		push @contents, $_ if good_location $location.'/'.$_ and $self->item_exists( $location.'/'.$_ );
	}
	return @contents;
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
	my $self          = shift;
	my $true_location = $self->content_base;

	throw_error Internal => "Won't empty all content, this looks too dangerous" if (
		-d "$true_location/.git"
		or
		-f "$true_location/Makefile.PL"
	);

	File::Path::remove_tree( $content_base, {keep_root => 1} );
}

sub delete_item {
	my $self = shift;
	my $location = shift->location;

	throw_error Internal => "Use empty_all_content instead to delete the root" if "$location" eq '/';
	throw_error Internal => "Bad location $location" unless good_location $location;

	my $true_location = $self->true_location( $location );
	File::Path::remove_tree( $true_location );
}

register_plugin();

1;
