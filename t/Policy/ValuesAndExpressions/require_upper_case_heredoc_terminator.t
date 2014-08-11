use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::RequireUpperCaseHeredocTerminator;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';

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
--- dscr: Basic passing w/double quoted
--- failures: 0
--- params:
--- input
print <<"QUOTE_1";
Four score and seven years ago...
QUOTE_1

===
--- dscr: Basic passing w/single quoted
--- failures: 0
--- params:
--- input
print <<'QUOTE_1';
Four score and seven years ago...
QUOTE_1

===
--- dscr: Basic passing w/bare word
--- failures: 0
--- params:
--- input
print <<QUOTE_1;
Four score and seven years ago...
QUOTE_1

===
--- dscr: Double quoted failure
--- failures: 1
--- params:
--- input
print <<"endquote";
Four score and seven years ago...
endquote

===
--- dscr: Single quoted failure
--- failures: 1
--- params:
--- input
print <<"endquote";
Four score and seven years ago...
endquote

===
--- dscr: Bareword failure
--- failures: 1
--- params:
--- input
print <<endquote;
Four score and seven years ago...
endquote

===
--- dscr: RT #27073: Spaces before HEREDOC token
--- failures: 0
--- params:
--- input
print <<  'END_QUOTE';
The only thing we have to fear is fear itself...
END_QUOTE

