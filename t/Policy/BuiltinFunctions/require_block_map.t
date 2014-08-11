use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::RequireBlockMap;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::RequireBlockMap';

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
map {$_++}   @list;
@foo = map {$_++}   @list;
map( {$_++}   @list );
@foo = map( {$_++}   @list );
map();
@foo = map();
{map}; # for Devel::Cover
malp $_++, @list; # deliberately misspell map

===
--- dscr: Basic failure
--- failures: 2
--- params:
--- input
map $_++, @list;
@foo = map $_++, @list;

===
--- dscr: Things that may look like a map, but aren't
--- failures: 0
--- params:
--- input
$hash1{map} = 1;
%hash2 = (map => 1);

