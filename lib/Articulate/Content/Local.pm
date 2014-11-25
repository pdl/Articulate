package Articulate::Content::Local;
use Dancer ':syntax';
use Exporter::Declare;
default_exports qw(get_content set_content get_meta set_meta);

use YAML;
use File::Path;

=head1 NAME

Articulate::Content::Local - store your content locally

=cut

my $content_base = config->{appdir}.'/content/';

sub ensure_exists { 
	my $true_location_full = shift // return undef;
	my $true_location = $true_location_full =~ s~[^/]+\.[^/]+$~~r;
	unless (-d $true_location) {
		File::Path::make_path $true_location;
	}
	return -d $true_location ? $true_location_full : die;
}

sub good_location {
	my $re_slug   = qr~[a-zA-Z](?:|[a-zA-Z0-9\-]*[a-zA-Z0-9])~;
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
