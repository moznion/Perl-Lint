use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::RequireQuotedHeredocTerminator;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';

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
--- dscr: Basic failure
--- failures: 1
--- params:
--- input
print <<END_QUOTE;
Four score and seven years ago...
END_QUOTE

===
--- dscr: Single quote passing
--- failures: 0
--- params:
--- input
print <<'END_QUOTE';
Four score and seven years ago...
END_QUOTE

===
--- dscr: Double quote passing
--- failures: 0
--- params:
--- input
print <<"END_QUOTE";
Four score and seven years ago...
END_QUOTE

===
--- dscr: RT# 25085: Spaces before HEREDOC token - w/ double quotes
--- failures: 0
--- params:
--- input
print <<  "END_QUOTE";
Four score and seven years ago...
END_QUOTE

===
--- dscr: RT# 25085: Spaces before HEREDOC token - w/ single quotes
--- failures: 0
--- params:
--- input
print <<  'END_QUOTE';
The only thing we have to fear is fear itself...
END_QUOTE

