use strict;
use warnings;
use Perl::Lint::Policy::TestingAndDebugging::ProhibitNoStrict;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'TestingAndDebugging::ProhibitNoStrict';

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
--- dscr: strictures disabled
--- failures: 1
--- params: {}
--- input
package foo;
no strict;

===
--- dscr: selective strictures disabled
--- failures: 1
--- params: {}
--- input
package foo;
no strict 'refs', 'vars';

===
--- dscr: selective strictures disabled
--- failures: 1
--- params: {}
--- input
package foo;
no strict qw(vars refs subs);

===
--- dscr: allowed no strict
--- failures: 0
--- params: {prohibit_no_strict => {allow => 'vars refs subs'}}
--- input
package foo;
no strict "vars", 'refs', "subs";

===
--- dscr: partially allowed no strict
--- failures: 1
--- params: {prohibit_no_strict => {allow => 'VARS SUBS'}}
--- input
package foo;
no strict "vars", "refs", 'subs';

===
--- dscr: partially allowed no strict
--- failures: 1
--- params: {prohibit_no_strict => {allow => 'VARS SUBS'}}
--- input
package foo;
no strict qw(vars refs subs);

===
--- dscr: allow no strict, mixed case config
--- failures: 0
--- params: {prohibit_no_strict => {allow => 'RefS SuBS'}}
--- input
package foo;
no strict qw(refs subs);

===
--- dscr: allow no strict, comma-delimimted config
--- failures: 0
--- params: {prohibit_no_strict => {allow => 'refs,subs'}}
--- input
package foo;
no strict "refs", "subs";

===
--- dscr: wrong case, funky config
--- failures: 1
--- params: {prohibit_no_strict => {allow => 'REfs;vArS'}}
--- input
package foo;
no strict "refs", 'vars', "subs";

