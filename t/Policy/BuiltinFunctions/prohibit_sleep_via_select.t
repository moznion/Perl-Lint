use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitSleepViaSelect;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitSleepViaSelect';

filters {
    params => [qw/eval/],
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: sleep, as list
--- failures: 1
--- params:
--- input
select( undef, undef, undef, 0.25 );

===
--- dscr: sleep, as list w/var
--- failures: 1
--- params:
--- input
select( undef, undef, undef, $time );

===
--- dscr: sleep, as built-in
--- failures: 1
--- params:
--- input
select undef, undef, undef, 0.25;

===
--- dscr: select on read
--- failures: 0
--- params:
--- input
select $vec, undef, undef, 0.25;

===
--- dscr: select on write
--- failures: 0
--- params:
--- input
select undef, $vec, undef, 0.25;

===
--- dscr: select on error
--- failures: 0
--- params:
--- input
select undef, undef, $vec, 0.25;

===
--- dscr: select as word
--- failures: 0
--- params:
--- input
$foo{select};

===
--- dscr: With three undefs, none of them the timeout. RT #37416
--- failures: 0
--- params:
--- input
# Now block until the GUI passes the range back
    my $rin = '';
    my $rout = '';
    vec($rin, $parent->fileno(), 1) = 1;
    if (select($rout=$rin,undef,undef,undef)) {
     my $line;
     recv($parent, $line, 1000, 0);
     ($first, $last) = split ' ', $line;
    }

