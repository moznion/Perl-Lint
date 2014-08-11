use strict;
use warnings;
use Perl::Lint::Policy::CodeLayout::RequireTrailingCommas;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'CodeLayout::RequireTrailingCommas';

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
($foo,
 $bar,
 $baz
);
@list = ($foo, $bar, $baz);
@list = some_function($foo, $bar, $baz);
@list = ($baz);
@list = ();

@list = (
);

@list = ($baz
);

@list = ($baz
        );

# not a straight assignment
@list = ((1,2,3),(
 1,
 2,
 3
));

===
--- dscr: Basic failure
--- failures: 3
--- params:
--- input
@list = ($foo,
         $bar,
         $baz);

@list = ($foo,
         $bar,
         $baz
        );

@list = ($foo,
         $bar,
         $baz
);

===
--- dscr: List assignment
--- failures: 0
--- params:
--- input
@list = ($foo,
         $bar,
         $baz,);

@list = ($foo,
         $bar,
         $baz,
);

@list = ($foo,
         $bar,
         $baz,
        );

===
--- dscr: Conditionals and mathematical precedence
--- failures: 0
--- params:
--- input
$foo = ( 1 > 2 ?
         $baz  :
         $nuts );

$bar = ( $condition1
         && $condition2
         || $condition3 );


# These were reported as false-positives.
# See http://rt.cpan.org/Ticket/Display.html?id=18297

$median = ( $times[ int $array_size / 2 ] +
            $times[ int $array_size / 2  - 1 ]) / 2;

===
--- dscr: code coverage
--- failures: 1
--- params:
--- input
@list = ($foo,
         $bar,
         $baz --
         );

