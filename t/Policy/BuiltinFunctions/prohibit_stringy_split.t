use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitStringySplit;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitStringySplit';

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
# Scalar arg
split $pattern;
split $pattern, $string;
split $pattern, $string, 3;

# Scalar arg, w/ parens
split($pattern);
split($pattern), $string;
split($pattern), $string, 3;

# Regex arg
split //;
split //, $string;
split //, $string, 3;

# Regex arg, w/ parens
split( // );
split( // ), $string;
split( // ), $string, 3;

$foo{split}; # for Devel::Cover
{split}; # for Devel::Cover

===
--- dscr: Basic failure
--- failures: 24
--- params:
--- input
# Single quote
split 'pattern';
split 'pattern', $string;
split 'pattern', $string, 3;

# Double quote
split "pattern";
split "pattern", $string;
split "pattern", $string, 3;

# Single reg quote
split q{pattern};
split q{pattern}, $string;
split q{pattern}, $string, 3;

# Double reg quote
split qq{pattern};
split qq{pattern}, $string;
split qq{pattern}, $string, 3;

# Single quote, w/ parens
split('pattern');
split('pattern'), $string;
split('pattern'), $string, 3;

# Double quote, w/ parens
split("pattern");
split("pattern"), $string;
split("pattern"), $string, 3;

# Single reg quote, w/ parens
split(q{pattern});
split(q{pattern}), $string;
split(q{pattern}), $string, 3;

# Double reg quote, w/ parens
split(qq{pattern});
split(qq{pattern}), $string;
split(qq{pattern}), $string, 3;

===
--- dscr: Special split on space
--- failures: 0
--- params:
--- input
split ' ';
split ' ', $string;
split ' ', $string, 3;

split( " " );
split( " " ), $string;
split( " " ), $string, 3;

split( q{ }  );
split( q{ }  ), $string;
split( q{ }  ), $string, 3;

split( qq{ }  );
split( qq{ }  ), $string;
split( qq{ }  ), $string, 3;

===
--- dscr: Split oddities
--- failures: 0
--- params:
--- input
# These might be technically legal, but they are so hard
# to understand that they might as well be outlawed.

split @list;
split( @list );

