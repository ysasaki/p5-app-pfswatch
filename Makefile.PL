use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'App::pfswatch',
    VERSION_FROM => "lib/App/pfswatch.pm",
    ABSTRACT =>
        'A simple utility that detects changes in a filesystem and run given command.',
    PREREQ_PM => {
        'ExtUtils::MakeMaker'     => 6.31,
        'ExtUtils::Install'       => 1.46,
        'Filesys::Notify::Simple' => 0.07,
        'Regexp::Assemble'        => 0.34,
    },
    META_MERGE => {
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            bugtracker => 'https://github.com/ysasaki/p5-app-pfswatch/issues',
            repository => 'git://github.com/ysasaki/p5-app-pfswatch.git',
        },
    },
    LICENSE   => 'perl',
    EXE_FILES => ['bin/pfswatch'],
);
