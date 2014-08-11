#!perl

use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitExcessComplexity;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitExcessComplexity';

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
--- dscr: parm-based pass
--- failures: 0
--- params: {prohibit_excess_complexity => {max_mccabe => 100}}
--- input
sub test_sub {
    if ( $foo && $bar || $baz ) {
        open my $fh, '<', $file or die $!;
    }
    elsif ( $blah >>= some_function() ) {
        return if $barf;
    }
    else {
        $results = $condition ? 1 : 0;
    }
    croak unless $result;

    while( $condition ){ frobulate() }
    until( $foo > $baz ){ blech() }
}

===
--- dscr: parm-based failure
--- failures: 1
--- params: {prohibit_excess_complexity => {max_mccabe => 1}}
--- input
sub test_sub {
    if ( $foo && $bar || $baz ) {
        open my $fh, '<', $file or die $!;
    }
    elsif ( $blah >>= some_function() ) {
        return if $barf;
    }
    else {
        $results = $condition ? 1 : 0;
    }
    croak unless $result;
}

===
--- dscr: failure with default mccabee
--- failures: 1
--- params:
--- input
sub test_sub {
    if ($foo && $bar || $buz and $qux or $hoge) {
        $foo ||= 1;
    }
    elsif ($fuga xor $piyo) {
        $bar &&= 1;
    }
    else {
        $buz = $qux ? 1 : 0;
    }

    unless (0) {}
    while (0) {}
    until (1) {}
    for my $item ($items) {}
    foreach my $e ($elements) {}

    $blah >>= some_function() if 1;
    $blahblah <<= some_function() unless 0;

    if (1) {}
}

===
--- dscr: no-op sub
--- failures: 0
--- params:
--- input
sub test_sub {
}

