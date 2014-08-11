use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitMismatchedOperators;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitMismatchedOperators';

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
if (1 == 1 || 1 != 1 || 1 > 1 || 1 >= 1 || 1 < 1 || 1 <= 1) {}
if (1 + 1 || 1 - 1 || 1 * 1 || 1 / 1) {}

if ($a == 1 || $a != 1 || $a > 1 || $a >= 1 || $a < 1 || $a <= 1) {}
if ($a + 1 || $a - 1 || $a * 1 || $a / 1) {}
$a += 1;
$a -= 1;
$a *= 1;
$a /= 1;

if ($a == $a || $a != $a || $a > $a || $a >= $a || $a < $a || $a <= $a) {}
if ($a + $a || $a - $a || $a * $a || $a / $a) {}
$a += $a;
$a -= $a;
$a *= $a;
$a /= $a;

if ('' eq '' || '' ne '' || '' gt '' || '' lt '' || '' ge '' || '' le '' || '' . '') {}
if ('' eq $a || '' ne $a || '' gt $a || '' lt $a || '' ge $a || '' le $a || '' . $a) {}

===
--- dscr: Basic failure
--- failures: 39
--- params:
--- input
if ('' == 1 || '' != 1 || '' > 1  || '' >= 1 || '' < 1 || '' <= 1) {}
if ('' + 1  || '' - 1  || '' * 1  || '' / 1) {}

if ($a == '' || $a != '' || $a > ''  || $a >= '' || $a < '' || $a <= '') {}
if ($a + ''  || $a - ''  || $a * ''  || $a / '') {}
$a += '';
$a -= '';
$a *= '';
$a /= '';

if ($a eq 1 || $a ne 1 || $a lt 1 || $a gt 1 || $a le 1 || $a ge 1 || $a . 1) {}
if ('' eq 1 || '' ne 1 || '' lt 1 || '' gt 1 || '' le 1 || '' ge 1 || '' . 1) {}
$a .= 1;

===
--- dscr: 'foo' x 15 x 'bar' is OK ( RT #54524 )
--- failures: 0
--- params:
--- input
'foo' x 15 . 'bar';
( 'foo' . ' ' ) x 15 . 'bar';
@foo x 15 . 'bar';
( 1, 2, 5 ) x 15 . 'bar';

===
--- dscr: File operators passing
--- failures: 0
--- params:
--- input
-M 'file' > 0;
-r 'file' < 1;
-w 'file' != 1;
-x 'file' == 0;
-o 'file' == 1234;
-R 'file' != 3210;
-W 'file' == 4321;
-X 'file' != 5678;
-O 'file' == 9876l;
-e 'file' == 1 && -z 'file';
-s 'file' / 1024;
-f 'file' == 1 && -d 'file' != 1;
-l 'file' && !-p 'file';
-S 'file' == 1 && -b 'file' != 1;
-c 'file' + 1;
-t 'file' > 1;
-u 'file' * 123;
-g 'file' != 1;
-k 'file' - -T 'file';
-B 'file' < 1;
-M 'file' + -A 'file';
(-M 'file') > 0 || -M 'file' > 0;

===
--- dscr: File operators failure
--- failures: 25
--- params:
--- input
-M 'file' gt "0";
-r 'file' lt "1";
-w 'file' ne "1";
-x 'file' eq "0";
-o 'file' eq "1234";
-R 'file' ne "3210";
-W 'file' eq "4321";
-X 'file' ne "5678";
-O 'file' eq "9876l";
-e 'file' eq "1";
-z 'file' ne "1";
-s 'file' eq "1024";
-f 'file' eq "1";
-d 'file' ne "1";
-l 'file' eq "1";
-S 'file' eq "1";
-b 'file' ne "1";
-c 'file' eq "1";
-t 'file' gt "1";
-u 'file' eq "123";
-g 'file' ne "1";
-k 'file' eq "1";
-T 'file' ne "1";
-B 'file' lt "1";
-A 'file' eq "1";

