use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitNoisyQuotes;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitNoisyQuotes';

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
$var = q{'};
$var = q{"};
$var = q{!!};
$var = q{||};
$var = "!!!";
$var = '!!!';
$var = 'a';
$var = "a";
$var = '1';
$var = "1";

===
--- dscr: Basic failure
--- failures: 4
--- params:
--- input
$var = "!";
$var = '!';
$var = '!!';
$var = "||";

===
--- dscr: overload pragma
--- failures: 0
--- params:
--- input
use overload '""';

===
--- dscr: Parentheses, braces, brackets
--- failures: 0
--- params:
--- input
$var = '(';
$var = ')';
$var = '{';
$var = '}';
$var = '[';
$var = ']';

$var = '{(';
$var = ')}';
$var = '[{';
$var = '[}';
$var = '[(';
$var = '])';

$var = "(";
$var = ")";
$var = "{";
$var = "}";
$var = "[";
$var = "]";

$var = "{(";
$var = ")]";
$var = "({";
$var = "}]";
$var = "{[";
$var = "]}";

