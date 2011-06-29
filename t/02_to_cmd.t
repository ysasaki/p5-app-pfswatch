use strict;
use warnings;
use Test::More;
use App::fswatch;

my @tests = (
    [ 'ls -l',   [qw/ls -l/], 'split by space' ],
    [ 'ls  -l',  [qw/ls -l/], 'ignore spaces' ],
    [ ' ls -l ', [qw/ls -l/], 'trimmed spaces' ],
);

plan tests => scalar @tests;

my $watcher = App::fswatch->new;
my $run     = sub {
    my ( $in, $out, $msg ) = @_;
    is_deeply [ $watcher->string_to_cmd($in) ], $out, $msg;
};

$run->(@$_) for @tests;
