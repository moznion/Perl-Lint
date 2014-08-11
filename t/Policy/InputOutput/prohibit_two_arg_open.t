use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::ProhibitTwoArgOpen;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::ProhibitTwoArgOpen';

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
--- dscr: basic failures
--- failures: 16
--- params:
--- input
open $fh, ">$output";
open($fh, ">$output");
open($fh, ">$output") or die;

open my $fh, ">$output";
open(my $fh, ">$output");
open(my $fh, ">$output") or die;

open FH, ">$output";
open(FH, ">$output");
open(FH, ">$output") or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open FH, ">$output" or die;
open $fh, ">$output" or die;
open my $fh, ">$output" or die;

open $fh, q{>$output};
open $fh, qq{>$output};
open ($fh, q{>$output});
open ($fh, qq{>$output});

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
open $fh, '>', $output;
open($fh, '>', $output);
open($fh, '>', $output) or die;

open my $fh, '>', $output;
open(my $fh, '>', $output);
open(my $fh, '>', $output) or die;

open FH, '>', $output;
open(FH, '>', $output);
open(FH, '>', $output) or die;

#This are tricky because the Critic can't
#tell where the expression really ends
# open $fh, '>', $output or die;
open my $fh, '>', $output or die;
open FH, '>', $output or die;

open $fh, q{>}, q{$output};
open $fh, qq{>}, qq{$output};
open ($fh, q{>}, q{$output});
open ($fh, qq{>}, qq{$output});

$foo{open}; # not a function call

===
--- dscr: no three-arg equivalent passes
--- failures: 0
--- params:
--- input
open( STDOUT, '>&STDOUT' );
open( STDIN, '>&STDIN' );
open( STDERR, '>&STDERR' );

open( \*STDOUT, '>&STDERR' );
open( *STDOUT, '>&STDERR' );
open( STDOUT, '>&STDERR' );

# These are actually forks
open FH, '-|';
open FH, '|-';

open FH, q{-|};
open FH, qq{-|};
open FH, "-|";

# Other file modes.
open( \*STDOUT, '>>&STDERR' );
open( \*STDOUT, '<&STDERR' );
open( \*STDOUT, '+>&STDERR' );
open( \*STDOUT, '+>>&STDERR' );
open( \*STDOUT, '+<&STDERR' );

===
--- dscr: pass with "use 5.005"
--- failures: 0
--- params:
--- input
open $fh, ">$output";
use 5.005;

===
--- dscr: fail with "use 5.006"
--- failures: 1
--- params:
--- input
open $fh, ">$output";
use 5.006;

===
--- dscr: rt44554 two arg open should fail
--- failures: 1
--- params:
--- input
open my $a, 'testing' or die 'error: ', $!;

