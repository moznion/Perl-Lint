#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitImplicitNewlines;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitImplicitNewlines';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
$x = "foo";
$x = 'foo';
$x = q{foo};
$x = qq{foo};
$x = "foo\n";
$x = "foo\r";

$x = <<'EOF';
1
2
EOF

$x = <<"EOF";
1
2
EOF

===
--- dscr: Basic failure
--- failures: 5
--- params:
--- input
$x = "1
2";
$x = '1
2';
$x = qq{1
2};
$x = q{1
2};
$x = "12
";

===
--- dscr: Bad whitespace usage, but allowed
--- failures: 0
--- params:
--- input
$x = q
<1>;

$x = qq
<1>;
