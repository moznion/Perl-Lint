#!perl

use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitEscapedCharacters;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitEscapedCharacters';

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
"\t\r\n\\";
"\N{DELETE}\N{ACKNOWLEDGE}\N{CANCEL}Z";
"\"\'\0";
'\x7f';
q{\x7f};

===
--- dscr: Basic failure
--- failures: 3
--- params:
--- input
"\127\006\030Z";
"\x7F\x06\x22Z";
qq{\x7F\x06\x22Z};
