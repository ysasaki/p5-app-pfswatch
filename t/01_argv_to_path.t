use strict;
use warnings;
use Test::More tests => 2;
use App::fswatch;

my $watcher = App::fswatch->new;

is_deeply [ $watcher->argv_to_path(qw(/tmp /hoge)) ], [qw(/hoge /tmp)], 'sorted';
is_deeply [ $watcher->argv_to_path() ], ['.'], 'push . if no args';
