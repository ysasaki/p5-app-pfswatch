use strict;
use warnings;
use Test::More tests => 1;
use App::pfswatch;

my $watcher = App::pfswatch->new;
isa_ok $watcher->ignored_pattern, 'Regexp';
