package Articulate::Storage::Local;
use Articulate::Storage::Common;
use Dancer ':syntax';
use Dancer::Plugin;
use Moo;
use File::Path;
use IO::All;
use YAML;

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
			// die ('appdir not set')
		).'/content/';
	unless (-d $content_base) {
		File::Path::make_path $content_base;
		die ('Could not initialise content base') unless (-d $content_base);
	}
	return $content_base;
}

sub ensure_exists {
	my $self = shift;
	my $true_location_full = shift // return undef;
	my $true_location = $true_location_full =~ s~[^/]+\.[^/]+$~~r;
	unless (-d $true_location) {
		File::Path::make_path $true_location;
	}
	return -d $true_location ? $true_location_full : die ('Does not exist');
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
	my $item     = shift;
	my $location = $item->location;
	die "Bad location $location" unless good_location $location;
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
	die "Bad location $location" unless good_location $location;
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
	die "Bad location ".$location unless good_location $location;
	my $fn = $self->ensure_exists( $self->true_location( $location . '/meta.yml' ) );
	YAML::DumpFile($fn, $item->meta) or die;
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
	die "Bad location ".$location unless good_location $location;
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
	my $location = shift->location;
	die "Bad location $location" unless good_location $location;
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
	my $location = shift;
	die "Bad location $location" unless good_location $location;
	my $fn = $self->true_location( $location . '/content.blob' );
	open my $fh, '<', $fn or return undef;
	return join '', <$fh>;
}

=head3 set_content

	$storage->set_content('zone/public/article/hello-world', $blob);

Places content at that location.

=cut


sub set_content {
	my $self = shift;
	my $item = shift;
	my $location = $item->location;
	die "Bad location $location" unless good_location $location;
	my $fn = $self->ensure_exists( $self->true_location( $location . '/content.blob' ) );
	open my $fh, '>', $fn or return undef;
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
	die "Bad location ".$location unless good_location $location;
	{
		my $fn = ensure_exists true_location( $location . '/content.blob' );
		open my $fh, '>', $fn or return undef;
		print $fh $item->content;
		close $fh;
	}
	{
		my $fn = ensure_exists true_location( $location . '/meta.yml' );
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
	die "Bad location $location" unless good_location $location;
	return -e $self->true_location( $location . '/meta.yml' );
}

=head3 list_items

	$storage->list_items ('/zone/public'); # 'hello-world', 'second-item' )

Returns a list of items in the.

=cut


sub list_items {
	my $self = shift;
	my $location = shift->location;
	die "Bad location $location" unless good_location $location;
	my $true_location = $self->true_location( $location );
	my @contents;
	return @contents unless -d $true_location;
	opendir (my $dh, $true_location) or die ('Could not open '.$true_location);
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

sub empty_content {
	File::Path::remove_tree( $content_base, {keep_root => 1} );
}

register_plugin();

1;
