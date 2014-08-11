#!perl

use strict;
use warnings;
use Perl::Lint::Policy::TestingAndDebugging::ProhibitProlongedStrictureOverride;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'TestingAndDebugging::ProhibitProlongedStrictureOverride';

filters {
    params => [qw/eval/], # TODO wrong!
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: standard pass
--- failures: 0
--- params:
--- input
use strict;
no strict;

===
--- dscr: standard fail
--- failures: 1
--- params:
--- input
use strict;
no strict;
print 1;
print 2;
print 3;
print 4;

===
--- dscr: pass that's almost to fail
--- failures: 0
--- params:
--- input
use strict;
no strict;
print 1;
print 2;
print 3;

===
--- dscr: in a block
--- failures: 0
--- params:
--- input
use strict;
sub foo {
    no strict;
}
print 1;
print 2;
print 3;
print 4;

===
--- dscr: long fail in a block
--- failures: 1
--- params:
--- input
use strict;
sub foo {
    no strict;
    print 1;
    print 2;
    print 3;
    print 4;
}

===
--- dscr: config override
--- failures: 0
--- params: {prohibit_prolonged_stricture_override => {statements => 6}}
--- input
use strict;
sub foo {
    no strict;
    print 1;
    print 2;
    print 3;
    print 4;
    print 5;
    print 6;
}
