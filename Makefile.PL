use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'Articulate',
    AUTHOR              => q{Daniel Perrett <perrettdl@googlemail.com>},
    VERSION_FROM        => 'lib/Articulate.pm',
    ABSTRACT            => 'Lightweight Perl CMS Framework',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'        => 0.98, # needs a reasonably modern version
        'YAML'              => 0,
        'Dancer'            => 1.3118,
        'File::Path'        => 0, #implied by IO::All but just in case
        'Module::Load'      => 0,
        'IO::All'           => 0,
        'Digest::SHA'       => 0,
        'Exporter::Declare' => 0,
        'Text::Markdown'    => 0, # chances are you'll need it
	'MooX::Singleton'   => 0, # for now at least
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Articulate-*' },
);
