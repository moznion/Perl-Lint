use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::RequireGlobFunction;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::RequireGlobFunction';

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
--- dscr: glob via <...>
--- failures: 1
--- params:
--- input
@files = <*.pl>;

===
--- dscr: glob via <...> in foreach
--- failures: 1
--- params:
--- input
foreach my $file (<*.pl>) {
    print $file;
}

===
--- dscr: Multiple globs via <...>
--- failures: 2
--- params:
--- input
@files = (<*.pl>, <*.pm>);

===
--- dscr: I/O
--- failures: 0
--- params:
--- input
while (<$fh>) {
    print $_;
}

