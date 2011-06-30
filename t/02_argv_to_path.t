use strict;
use warnings;
use Test::More tests => 2;
use App::pfswatch;

my $watcher = App::pfswatch->new;

is_deeply [ $watcher->argv_to_path(qw(/tmp /hoge)) ], [qw(/hoge /tmp)], 'sorted';
is_deeply [ $watcher->argv_to_path() ], ['.'], 'push . if no args';
