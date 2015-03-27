use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitQuotesAsQuotelikeOperatorDelimiters;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitQuotesAsQuotelikeOperatorDelimiters';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
$x = q{};
$x = qq{};
$x = qx{};
$x = qr{};
$x = qw{};

$x =~ //;
$x =~ m{};
$x =~ s{}{};
$x =~ tr{}{};
$x =~ y{}{};

$x = qx'';
$x = qr'';

$x =~ m'';
$x =~ s''';

===
--- dscr: Basic failure
--- failures: 15
--- params:
--- input
# TODO
$x = q'';
$x = qq'';
$x = qw'';

# $x =~ tr''';
# $x =~ y''';

$x = q"";
$x = qq"";
$x = qx"";
$x = qr"";
$x = qw"";

$x =~ m"";
# $x =~ s""";
# $x =~ tr""";
# $x =~ y""";

$x = q``;
$x = qq``;
$x = qx``;
$x = qr``;
$x = qw``;

$x =~ m``;
# $x =~ s```;
# $x =~ tr```;
# $x =~ y```;

===
--- dscr: single_quote_allowed_operators = m q qq qr qw qx s tr y
--- failures: 0
--- params: {single_quote_allowed_operators => 'm q qq qr qw qx s tr y'}
--- input
$x = q'';
$x = qq'';
$x = qx'';
$x = qr'';
$x = qw'';

$x =~ m'';
$x =~ s''';
$x =~ tr''';
$x =~ y''';

===
--- dscr: single_quote_allowed_operators =
--- failures: 6
--- params: {single_quote_allowed_operators => ''}
--- input
$x = q'';
$x = qq'';
$x = qx'';
$x = qr'';
$x = qw'';

$x =~ m'';
# $x =~ s''';
# $x =~ tr''';
# $x =~ y''';

===
--- dscr: double_quote_allowed_operators = m q qq qr qw qx s tr y
--- failures: 0
--- params: {double_quote_allowed_operators => 'm q qq qr qw qx s tr y'}
--- input
$x = q"";
$x = qq"";
$x = qx"";
$x = qr"";
$x = qw"";

$x =~ m"";
$x =~ s""";
$x =~ tr""";
$x =~ y""";

===
--- dscr: double_quote_allowed_operators =
--- failures: 6
--- params: {double_quote_allowed_operators => ''}
--- input
$x = q"";
$x = qq"";
$x = qx"";
$x = qr"";
$x = qw"";

$x =~ m"";
# $x =~ s""";
# $x =~ tr""";
# $x =~ y""";

===
--- dscr: back_quote_allowed_operators = m q qq qr qw qx s tr y
--- failures: 0
--- params: {back_quote_allowed_operators => 'm q qq qr qw qx s tr y'}
--- input
$x = q``;
$x = qq``;
$x = qx``;
$x = qr``;
$x = qw``;

$x =~ m``;
$x =~ s```;
$x =~ tr```;
$x =~ y```;

===
--- dscr: back_quote_allowed_operators =
--- failures: 6
--- params: {back_quote_allowed_operators => ''}
--- input
$x = q``;
$x = qq``;
$x = qx``;
$x = qr``;
$x = qw``;

$x =~ m``;
# $x =~ s```;
# $x =~ tr```;
# $x =~ y```;

===
--- dscr: no lint
--- failures: 4
--- params:
--- input
$x = q"";
$x = qq"";
$x = qx""; ## no lint
$x = qr"";
$x = qw"";

