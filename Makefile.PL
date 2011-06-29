use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'App::fswatch',
    VERSION_FROM => "lib/App/fswatch.pm",
    ABSTRACT     => 'Watch filesystem changes and run command.',
    PREREQ_PM    => {
        'ExtUtils::MakeMaker'     => 6.31,
        'ExtUtils::Install'       => 1.46,
        'Filesys::Notify::Simple' => 0.07,
        'Regexp::Assemble'        => 0.34,
    },
    LICENSE   => 'perl',
    EXE_FILES => ['bin/fswatch'],
);
