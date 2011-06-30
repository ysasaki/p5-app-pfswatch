use strict;
use Test::More tests => 2;

BEGIN { use_ok 'App::pfswatch' }
my @method = qw/
    new run argv_to_path ignored_pattern parse_argv
/;
can_ok 'App::pfswatch', @method;
