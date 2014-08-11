use strict;
use warnings;
use Perl::Lint::Policy::Modules::ProhibitConditionalUseStatements;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::ProhibitConditionalUseStatements';

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
--- dscr: pass, simple use
--- failures: 0
--- params:
--- input
use Foo::Bar;

===
--- dscr: pass, enclosing bare block
--- failures: 0
--- params:
--- input
{
use Foo::Bar;
}

===
--- dscr: pass, enclosing labeled bare block
--- failures: 0
--- params:
--- input
FOO: {
use Foo::Bar;
}

===
--- dscr: pass, enclosing subroutine
--- failures: 0
--- params:
--- input
sub foo {
use Foo::Bar;
}

===
--- dscr: pass, enclosing begin block
--- failures: 0
--- params:
--- input
BEGIN {
use Foo::Bar;
}

===
--- dscr: pass, enclosing do block
--- failures: 0
--- params:
--- input
do {
use Foo::Bar;
}

===
--- dscr: pass, enclosing string eval block
--- failures: 0
--- params:
--- input
eval "use Foo::Bar";

===
--- dscr: pass, enclosing if statement in string eval
--- failures: 0
--- params:
--- input
eval "if ($a == 1) { use Foo::Bar; }";

===
--- dscr: pass, enclosing string eval in if statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
eval "use Foo::Bar;";
}

===
--- dscr: pass, simple require
--- failures: 0
--- params:
--- input
require Foo::Bar;

===
--- dscr: pass, require in enclosing bare block
--- failures: 0
--- params:
--- input
{
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing labeled bare block
--- failures: 0
--- params:
--- input
FOO: {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing subroutine
--- failures: 0
--- params:
--- input
sub foo {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing begin block
--- failures: 0
--- params:
--- input
BEGIN {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing do block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing do following logical or
--- failures: 0
--- params:
--- input
$a == 1 || do {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing do following logical and
--- failures: 0
--- params:
--- input
$a && 1 || do {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing do following binary or
--- failures: 0
--- params:
--- input
$a == 1 or do {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing do following binary and
--- failures: 0
--- params:
--- input
$a == 1 and do {
require Foo::Bar;
}

===
--- dscr: pass, require enclosing string eval block
--- failures: 0
--- params:
--- input
eval "require Foo::Bar";

===
--- dscr: pass, require in enclosing if statement in string eval
--- failures: 0
--- params:
--- input
eval "if ($a == 1) { require Foo::Bar; }";

===
--- dscr: pass, require in enclosing string eval in if statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
eval "require Foo::Bar;";
}

===
--- dscr: pass, require in enclosing else statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
print 1;
} else {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing elsif statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
print 1;
} elsif ($a == 2) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing while statement
--- failures: 0
--- params:
--- input
while ($a == 1) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing continue statement
--- failures: 0
--- params:
--- input
while ($a == 1) {
print 1;
} continue {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing unless statement
--- failures: 0
--- params:
--- input
unless ($a == 1) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing until statement
--- failures: 0
--- params:
--- input
until ($a == 1) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing c-style for statement
--- failures: 0
--- params:
--- input
for ($a = 1; $a < $b; $a++) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing for statement
--- failures: 0
--- params:
--- input
for $a (1..$b) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing foreach statement
--- failures: 0
--- params:
--- input
foreach $a (@b) {
require Foo::Bar;
}

===
--- dscr: pass, require in enclosing if statement in begin block
--- failures: 0
--- params:
--- input
BEGIN {
if ($a == 1) {
require Foo::Bar;
}
}

===
--- dscr: pass, require in enclosing do-while block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
} while ($a == 1);

===
--- dscr: pass, require in enclosing do-until block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
} until ($a == 1);

===
--- dscr: pass, require in enclosing do-unless block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
} unless ($a == 1);

===
--- dscr: pass, require in enclosing do-for block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
} for (1..2);

===
--- dscr: pass, require in enclosing do-foreach block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
} foreach (@a);

===
--- dscr: pass, require in enclosing do-if block
--- failures: 0
--- params:
--- input
do {
require Foo::Bar;
} if ($a == 1);

===
--- dscr: pass, simple pragma
--- failures: 0
--- params:
--- input
use strict;

===
--- dscr: pass, pragma in enclosing bare block
--- failures: 0
--- params:
--- input
{
use strict;
}

===
--- dscr: pass, pragma in enclosing labeled bare block
--- failures: 0
--- params:
--- input
FOO: {
use strict;
}

===
--- dscr: pass, pragma in enclosing subroutine
--- failures: 0
--- params:
--- input
sub foo {
use strict;
}

===
--- dscr: pass, pragma in enclosing begin block
--- failures: 0
--- params:
--- input
BEGIN {
use strict;
}

===
--- dscr: pass, pragma in enclosing do block
--- failures: 0
--- params:
--- input
do {
use strict;
}

===
--- dscr: pass, pragma in enclosing do following logical or
--- failures: 0
--- params:
--- input
$a == 1 || do {
use strict;
}

===
--- dscr: pass, pragma in enclosing do following logical and
--- failures: 0
--- params:
--- input
$a && 1 || do {
use strict;
}

===
--- dscr: pass, pragma in enclosing do following binary or
--- failures: 0
--- params:
--- input
$a == 1 or do {
use strict;
}

===
--- dscr: pass, pragma in enclosing do following binary and
--- failures: 0
--- params:
--- input
$a == 1 and do {
use strict;
}

===
--- dscr: pass, pragma enclosing string eval block
--- failures: 0
--- params:
--- input
eval "use strict";

===
--- dscr: pass, pragma in enclosing if statement in string eval
--- failures: 0
--- params:
--- input
eval "if ($a == 1) { use strict; }";

===
--- dscr: pass, pragma in enclosing string eval in if statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
eval "use strict;";
}

===
--- dscr: pass, pragma in enclosing else statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
print 1;
} else {
use strict;
}

===
--- dscr: pass, pragma in enclosing elsif statement
--- failures: 0
--- params:
--- input
if ($a == 1) {
print 1;
} elsif ($a == 2) {
use strict;
}

===
--- dscr: pass, pragma in enclosing while statement
--- failures: 0
--- params:
--- input
while ($a == 1) {
use strict;
}

===
--- dscr: pass, pragma in enclosing continue statement
--- failures: 0
--- params:
--- input
while ($a == 1) {
print 1;
} continue {
use strict;
}

===
--- dscr: pass, pragma in enclosing unless statement
--- failures: 0
--- params:
--- input
unless ($a == 1) {
use strict;
}

===
--- dscr: pass, pragma in enclosing until statement
--- failures: 0
--- params:
--- input
until ($a == 1) {
use strict;
}

===
--- dscr: pass, pragma in enclosing c-style for statement
--- failures: 0
--- params:
--- input
for ($a = 1; $a < $b; $a++) {
use strict;
}

===
--- dscr: pass, pragma in enclosing for statement
--- failures: 0
--- params:
--- input
for $a (1..$b) {
use strict;
}

===
--- dscr: pass, pragma in enclosing foreach statement
--- failures: 0
--- params:
--- input
foreach $a (@b) {
use strict;
}

===
--- dscr: pass, pragma in enclosing if statement in begin block
--- failures: 0
--- params:
--- input
BEGIN {
if ($a == 1) {
use strict;
}
}

===
--- dscr: pass, pragma in enclosing do-while block
--- failures: 0
--- params:
--- input
do {
use strict;
} while ($a == 1);

===
--- dscr: pass, pragma in enclosing do-until block
--- failures: 0
--- params:
--- input
do {
use strict;
} until ($a == 1);

===
--- dscr: pass, pragma in enclosing do-unless block
--- failures: 0
--- params:
--- input
do {
use strict;
} unless ($a == 1);

===
--- dscr: pass, pragma in enclosing do-for block
--- failures: 0
--- params:
--- input
do {
use strict;
} for (1..2);

===
--- dscr: pass, pragma in enclosing do-foreach block
--- failures: 0
--- params:
--- input
do {
use strict;
} foreach (@a);

===
--- dscr: pass, pragma in enclosing do-if block
--- failures: 0
--- params:
--- input
do {
use strict;
} if ($a == 1);

===
--- dscr: failure, enclosing else statement
--- failures: 1
--- params:
--- input
if ($a == 1) {
print 1;
} else {
use Foo::Bar;
}

===
--- dscr: failure, enclosing elsif statement
--- failures: 1
--- params:
--- input
if ($a == 1) {
print 1;
} elsif ($a == 2) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing while statement
--- failures: 1
--- params:
--- input
while ($a == 1) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing continue statement
--- failures: 1
--- params:
--- input
while ($a == 1) {
print 1;
} continue {
use Foo::Bar;
}

===
--- dscr: failure, enclosing unless statement
--- failures: 1
--- params:
--- input
unless ($a == 1) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing until statement
--- failures: 1
--- params:
--- input
until ($a == 1) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing c-style for statement
--- failures: 1
--- params:
--- input
for ($a = 1; $a < $b; $a++) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing for statement
--- failures: 1
--- params:
--- input
for $a (1..$b) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing foreach statement
--- failures: 1
--- params:
--- input
foreach $a (@b) {
use Foo::Bar;
}

===
--- dscr: failure, enclosing if statement in begin block
--- failures: 1
--- params:
--- input
BEGIN {
if ($a == 1) {
use Foo::Bar;
}
}

===
--- dscr: failure, enclosing eval statement
--- failures: 1
--- params:
--- input
eval {
use Foo::Bar;
};

===
--- dscr: failure, enclosing if statement in eval
--- failures: 1
--- params:
--- input
eval {
if ($a == 1) {
use Foo::Bar;
}
};

===
--- dscr: failure, enclosing do following logical or
--- failures: 1
--- params:
--- input
$a == 1 || do {
use Foo::Bar;
}

===
--- dscr: failure, enclosing do following logical and
--- failures: 1
--- params:
--- input
$a && 1 || do {
use Foo::Bar;
}

===
--- dscr: failure, enclosing do following binary or
--- failures: 1
--- params:
--- input
$a == 1 or do {
use Foo::Bar;
}

===
--- dscr: failure, enclosing do following binary and
--- failures: 1
--- params:
--- input
$a == 1 and do {
use Foo::Bar;
}

===
--- dscr: failure, enclosing do-while block
--- failures: 1
--- params:
--- input
do {
use Foo::Bar;
} while ($a == 1);

===
--- dscr: failure, enclosing do-until block
--- failures: 1
--- params:
--- input
do {
use Foo::Bar;
} until ($a == 1);

===
--- dscr: failure, enclosing do-unless block
--- failures: 1
--- params:
--- input
do {
use Foo::Bar;
} unless ($a == 1);

===
--- dscr: failure, enclosing do-for block
--- failures: 1
--- params:
--- input
do {
use Foo::Bar;
} for (1..2);

===
--- dscr: failure, enclosing do-foreach block
--- failures: 1
--- params:
--- input
do {
use Foo::Bar;
} foreach (@a);

===
--- dscr: failure, enclosing do-if block
--- failures: 1
--- params:
--- input
do {
use Foo::Bar;
} if ($a == 1);

