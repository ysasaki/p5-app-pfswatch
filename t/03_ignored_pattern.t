use strict;
use warnings;
use Test::More tests => 1;
use App::fswatch;

my $watcher = App::fswatch->new;
isa_ok $watcher->ignored_pattern, 'Regexp';
