use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'App::pfswatch',
    VERSION_FROM => "lib/App/pfswatch.pm",
    AUTHOR       => 'Yoshihiro Sasaki <ysasaki at cpan.org>',
    ABSTRACT =>
        'A simple utility that detects changes in a filesystem and run given command.',
    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.31,
        'ExtUtils::Install'   => 1.46,
        'Test::Simple'        => 0.96,
    },
    PREREQ_PM => {
        'Filesys::Notify::Simple' => 0.07,
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
