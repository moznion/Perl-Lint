use strict;
use warnings;
use Perl::Lint::Policy::Miscellanea::ProhibitUnrestrictedNoLint;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Miscellanea::ProhibitUnrestrictedNoLint';

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
--- dscr: standard failures
--- failures: 4
--- params:
--- input
##no lint
## no lint
## no lint;
## no lint #blah,blah

===
--- dscr: slightly more complicated failures
--- failures: 4
--- params:
--- input
# just some spacing variations here...
$foo = $bar; ##  no lint
$foo = $bar; ##no lint

$foo = $bar; ## no lint ()
#$foo = $bar; ## no lint ''
#$foo = $bar; ## no lint ""
$foo = $bar; ## no lint qw()

===
--- dscr: unrestricted "no lint" on a sub block
--- failures: 5
--- params:
--- input

sub frobulate { ##no lint
    return $frob;
}

sub frobulate { ## no lint #blah,blah
    return $frob;
}

sub frobulate { ## no lint ''
    return $frob;
}

sub frobulate { ## no lint ""
    return $frob;
}

sub frobulate { ## no lint ()
    return $frob;
}

===
--- dscr: standard passes
--- failures: 0
--- params:
--- input

## no lint (shizzle)
## no lint 'shizzle'
## no lint "shizzle"
## no lint qw(shizzle) #blah,blah

$foo = $bar; ## no lint 'shizzle';
$foo = $bar; ## no lint "shizzle";
$foo = $bar; ## no lint (shizzle);
$foo = $bar; ## no lint qw(shizzle);


sub frobulate { ## no lint 'shizzle'
    return $frob;
}

sub frobulate { ## no lint "shizzle"
    return $frob;
}

sub frobulate { ## no lint (shizzle)
    return $frob;
}

sub fornicate { ## no lint qw(shizzle)
    return $forn;
}

