use strict;
use warnings;
use Perl::Lint::Policy::Modules::ProhibitExcessMainComplexity;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::ProhibitExcessMainComplexity';

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
--- dscr: param-based failure
--- failures: 0
--- params: { prohibit_excess_main_complexity => { max_mccabe => 10 } }
--- input
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

===
--- dscr: parm-based failure
--- failures: 1
--- params: { prohibit_excess_main_complexity => { max_mccabe => 9 } }
--- input
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

===
--- dscr: exclude code inside subroutines
--- failures: 0
--- params: { prohibit_excess_main_complexity => { max_mccabe => 1 } }
--- input
sub foo {
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

#main code here!
die if $condition;

sub bar {
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
--- dscr: empty module
--- failures: 0
--- params:
--- input

===
--- dscr: basic pass
--- failures: 0
--- params:
--- input

if ($foo && $bar || $baz and $qux or $foobar) {
    $hoge ||= 1;
    $fuga &&= 1;
    $piyo = 1 ? 1 : 0;
}
elsif ( $blah >>= some_function() xor $blah <<= some_function() ) {
}
else {
}

croak unless $result;

while () {}
until () {}
for (1..10) {}
foreach (1..10) {}

===
--- dscr: fail cuz over the default mccabe
--- failures: 1
--- params:
--- input
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
$hoge ||= 1;
