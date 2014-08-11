use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitInterpolationOfLiterals;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';

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
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
print "this is literal";
print qq{this is literal};

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
print 'this is literal';
print q{this is literal};

===
--- dscr: Code with all delimiters in configuration
--- failures: 0
--- params: {prohibit_interpolation_of_literals => {allow => 'qq( qq{ qq[ qq/'}}
--- input
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;

===
--- dscr: Code with not all delimiters in configuration
--- failures: 2
--- params: {prohibit_interpolation_of_literals => {allow => 'qq( qq{'}}
--- input
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;

===
--- dscr: Configuration with only delimiters, no operators
--- failures: 2
--- params: {prohibit_interpolation_of_literals => {allow => '() {}'}}
--- input
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;

===
--- dscr: Configuration with matching closing delimiters
--- failures: 2
--- params: {prohibit_interpolation_of_literals => {allow => 'qq() qq{}'}}
--- input
$sql = qq(select foo from bar);
$sql = qq{select foo from bar};
$sql = qq[select foo from bar];
$sql = qq/select foo from bar/;

===
--- dscr: Disallow interpolation if string contains single quote
--- failures: 2
--- params:
--- input
$sql = "it's me";
$sql = "\'";

===
--- dscr: Allow interpolation if string contains single quote, with option on.
--- failures: 0
--- params: {prohibit_interpolation_of_literals => {allow_if_string_contains_single_quote => 1}}
--- input
$sql = "it's me";
$sql = "\'";

===
--- dscr: allow double quotes if called for.
--- failures: 0
--- params:
--- input
$text = "Able was $I ere $I saw Elba";
$text = "$I think, therefore ...";
$text = "Anyone @home?";
$text = "Here we have\ta tab";
$text = "Able was \\$I ere \\$I saw Elba";
$text = "\\$I think, therefore ...";
$text = "Anyone \\@home?";
$text = "Here we have\\\ta tab";

===
--- dscr: prohibit double quotes if not called for
--- failures: 8
--- params:
--- input
$text = "Able was \$I ere \$I saw Elba";
$text = "\$I think, therefore ...";
$text = "Anyone \@home?";
$text = "Here we do not have\\ta tab";
$text = "Able was \\\$I ere \\\$I saw Elba";
$text = "\\\$I think, therefore ...";
$text = "Anyone \\\@home?";
$text = "Here we do not have\\\\ta tab";

===
--- dscr: Disallow interpolation if string contains single quote w/reg_double_quote
--- failures: 2
--- params:
--- input
$sql = qq{it's me};
$sql = qq{\'};

===
--- dscr: Allow interpolation if string contains single quote, with option on w/reg_double_quote
--- failures: 0
--- params: {prohibit_interpolation_of_literals => {allow_if_string_contains_single_quote => 1}}
--- input
$sql = qq{it's me};
$sql = qq{\'};

===
--- dscr: allow double quotes if called for w/reg_double_quote
--- failures: 0
--- params:
--- input
$text = qq{Able was $I ere $I saw Elba};
$text = qq{$I think, therefore ...};
$text = qq{Anyone @home?};
$text = qq{Here we have\ta tab};
$text = qq{Able was \\$I ere \\$I saw Elba};
$text = qq{\\$I think, therefore ...};
$text = qq{Anyone \\@home?};
$text = qq{Here we have\\\ta tab};

===
--- dscr: prohibit double quotes if not called for w/reg_double_quote
--- failures: 8
--- params:
--- input
$text = qq{Able was \$I ere \$I saw Elba};
$text = qq{\$I think, therefore ...};
$text = qq{Anyone \@home?};
$text = qq{Here we do not have\\ta tab};
$text = qq{Able was \\\$I ere \\\$I saw Elba};
$text = qq{\\\$I think, therefore ...};
$text = qq{Anyone \\\@home?};
$text = qq{Here we do not have\\\\ta tab};

