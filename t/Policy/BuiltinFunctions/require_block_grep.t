use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::RequireBlockGrep;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::RequireBlockGrep';

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
grep {$_ eq 'foo'}  @list;
@matches = grep {$_ eq 'foo'}  @list;
grep( {$_ eq 'foo'}  @list );
@matches = grep( {$_ eq 'foo'}  @list )
grep();
@matches = grep();
{grep}; # for Devel::Cover
grelp $_ eq 'foo', @list; # deliberately misspell grep

===
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
grep $_ eq 'foo', @list;
@matches = grep $_ eq 'foo', @list;

===
--- dscr: Things that may look like a grep, but aren't
--- failures: 0
--- params:
--- input
$hash1{grep} = 1;
%hash2 = (grep => 1);

