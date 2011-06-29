use strict;
use Test::More tests => 2;

BEGIN { use_ok 'App::pfswatch' }
can_ok 'App::pfswatch', qw/new run argv_to_path string_to_cmd ignored_pattern/;
