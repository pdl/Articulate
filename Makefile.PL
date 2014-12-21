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
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'        => 0,
        'YAML'              => 0,
        'Dancer'            => 1.3118,
        'File::Path'        => 0,
        'Module::Load'      => 0,
        'IO::All'           => 0,
        'Digest::SHA'       => 0,
        'Exporter::Declare' => 0,
        'Text::Markdown'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Articulate-*' },
);
