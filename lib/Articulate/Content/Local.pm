package Articulate::Content::Local;
use Dancer ':syntax';
use Exporter::Declare;
default_exports qw(get_content set_content get_meta set_meta get_settings);

use YAML;
use File::Path;

=head1 NAME

Articulate::Content::Local - store your content locally

=cut

my $content_base = config->{content_base} // config->{appdir}.'/content/';

unless (-d $content_base) {
	File::Path::make_path $content_base;
	die ('Could not initialise content base') unless (-d $content_base);
}

sub ensure_exists {
	my $true_location_full = shift // return undef;
	my $true_location = $true_location_full =~ s~[^/]+\.[^/]+$~~r;
	unless (-d $true_location) {
		File::Path::make_path $true_location;
	}
	return -d $true_location ? $true_location_full : die;
}

# This generates re_location, a regular expression for all possible locations

my $re_location;
my $s_slug  = '[a-zA-Z](?:|[a-zA-Z0-9\-]*[a-zA-Z0-9])';
my $re_slug = qr~$s_slug~;
{
	my $path_schema = {
		zone => {
			article => {
				# ...
			},
		},
		user => {},
	};
	my $_descend;
	$_descend = sub {
		my ($current, $stack) = @_;
		my $paths = [$stack];
		foreach my $key (keys %$current) {
			push @$paths, @{ $_descend->( $current->{$key}, [@$stack, $key] ) };
		}
		$paths;
	};
	my $s_location = '';
	foreach my $path ( @{ $_descend->( $path_schema, [] ) } ) {
		$s_location .= '|';
		foreach my $step (@$path) {
			$s_location .= $step.'/'.$s_slug;
		}
	}
	$s_location =~ s~^\|~~;
	$re_location = qr/^$s_location/;
}

sub good_location {
	my $location  = shift;
	return undef unless $location =~ m~^zone/$re_slug/article/$re_slug$~;
	return $location;
}

sub true_location {
	return $content_base . shift;
}

=head3 get_meta

	get_meta 'zone/public/article/hello-world'

Retrieves the metadata for the content at that location.

=cut

sub get_meta {
	my $location = shift;
	die "Bad location $location" unless good_location $location;
	my $fn = true_location $location . '/meta.yml';
	return YAML::LoadFile($fn) if -e $fn;
	return {};
}

=head3 set_meta

	set_meta 'zone/public/article/hello-world', {...}

Sets the metadata for the content at that location.

=cut

sub set_meta {
	my $location = shift;
	my $data = shift;
	die "Bad location $location" unless good_location $location;
	my $fn = ensure_exists true_location $location . '/meta.yml';
	return YAML::DumpFile($fn, $data);
}

=head3 patch_meta

	patch_meta 'zone/public/article/hello-world', {...}

Alters the metadata for the content at that location. Existing keys are retained.

CURRENTLY this affects top-level keys only, but a descent algorigthm is planned.

=cut

sub patch_meta {
	my $location = shift;
	my $data = shift;
	die "Bad location $location" unless good_location $location;
	my $fn = ensure_exists true_location $location . '/meta.yml';
	my $old_data = {};
	$old_data = YAML::LoadFile($fn) if -e $fn;
	return YAML::DumpFile($fn, merge_settings($old_data, $data));
}


=head3 get_settings

get_settings 'zone/public/article/hello-world'

Retrieves the settings for the content at that location.

=cut

sub get_settings {
	my $location = shift;
	die "Bad location $location" unless good_location $location;
	my @paths = split /\//, $location;
	my $current_path = true_location '/';
	my $settings = {};
	foreach my $p (@paths) {
		my $fn = $current_path . 'settings.yml';
		my $lvl_settings = {};
		$lvl_settings =	YAML::LoadFile($fn) if -e $fn;
		$settings = merge_settings ($settings, $lvl_settings)
	}
	return $settings;
}

=head3 merge_settings

	my $merged = merge_settings ($parent, $child);

=cut

sub merge_settings {
	my ($parent, $child) = @_;
	return {%$parent, %$child}; # todo: more
}

=head3 get_content

	get_content 'zone/public/article/hello-world'

Retrieves the content at that location.

=cut

sub get_content {
	my $location = shift;
	die "Bad location $location" unless good_location $location;
	my $fn = true_location $location . '/content.blob';
	open my $fh, '<', $fn or return undef;
	return join '', <$fh>;
}

=head3 set_content

	set_content 'zone/public/article/hello-world', $blob;

Places content at that location.

=cut


sub set_content {
	my $location = shift;
	my $data = shift;
	die "Bad location $location" unless good_location $location;
	my $fn = ensure_exists true_location $location . '/content.blob';
	open my $fh, '>', $fn or return undef;
	print $fh $data;
	close $fh;
	return $location;
}



1;
