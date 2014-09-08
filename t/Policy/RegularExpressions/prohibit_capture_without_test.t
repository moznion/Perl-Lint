use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitCaptureWithoutTest;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitCaptureWithoutTest';

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
--- dscr: use without regex
--- failures: 3
--- params:
--- input
my $foo = $1;
my @matches = ($1, $2);

===
--- dscr: void use without regex
--- failures: 1
--- params:
--- input
$1

===
--- dscr: regex but no check on success
--- failures: 1
--- params:
--- input
'some string' =~ m/(s)/;
my $s = $1;

===
--- dscr: inside a checkblock, but another regex overrides
--- failures: 1
--- params:
--- input
if (m/(.)/) {
   'some string' =~ m/(s)/;
   my $s = $1;
}

===
--- dscr: good passes
--- failures: 0
--- params:
--- input
if ($str =~ m/(.)/) {
   return $1;
}
elsif ($foo =~ s/(b)//) {
   $bar = $1;
}

if ($str =~ m/(.)/) {
   while (1) {
      return $1;
   }
}

while ($str =~ m/\G(.)/cg) {
   print $1;
}

print $0; # not affected by policy
print $_; # not affected by policy
print $f1; # not affected by policy

my $result = $str =~ m/(.)/;
if ($result) {
   return $1;
}

===
--- dscr: ternary passes
--- failures: 0
--- params:
--- input
print m/(.)/ ? $1 : 'undef';
print !m/(.)/ ? 'undef' : $1;
print s/(.)// ? $1 : 'undef';
print !s/(.)// ? 'undef' : $1;
$foo = m/(.)/ && $1;
$foo = !m/(.)/ || $1;
$foo = s/(.)// && $1;
$foo = !s/(.)// || $1;

===
--- dscr: Regression for PPI::Statement::Expressions
--- failures: 0
--- params:
--- input
if (m/(\d+)/xms) {
   $foo = ($1);
}

===
--- dscr: Regression for ternaries with structures
--- failures: 0
--- params:
--- input
$str =~ m/(.)/xms ? foo($1) : die;
$str =~ m/(.)/xms ? [$1] : die;
$str =~ m/(.)/xms ? { match => $1 } : die;

===
--- dscr: Failure to match throws exception - RT 36081.
--- failures: 0
--- params:
--- input
m/(foo)/ or die;
print $1, "\n";
m/(foo)/ or croak;
print $1, "\n";
m/(foo)/ or confess;
print $1, "\n";
m/(foo)/ || die;
print $1, "\n";
m/(foo)/ || croak;
print $1, "\n";
m/(foo)/ || confess;
print $1, "\n";

===
--- dscr: Failure to match throws exception (regex in outer block) - RT 36081.
--- failures: 0
--- params:
--- input
m/(foo)/ or die;
{
    print $1, "\n";
}

===
--- dscr: Failure to match throws exception (regex in inner block) - RT 36081.
--- failures: 1
--- params:
--- input
{
    m/(foo)/ or die;
}
print $1, "\n";

===
--- dscr: Boolean 'or' without known exception source is an error - RT 36081
--- failures: 1
--- params:
--- input
m/(foo)/ or my_exception_source( 'bar' );
print $1, "\n";

===
--- dscr: Recognize alternate exception sources if told about them - RT 36081
--- failures: 0
--- params: {prohibit_capture_without_test => {exception_source => 'my_exception_source my_die'}}
--- input
m/(foo)/ or my_exception_source( 'bar' );
print $1, "\n";
m/(foo)/ or $self->my_exception_source( 'bar' );
print $1, "\n";
m/(foo)/ or my_die( 'bar' );
print $1, "\n";
m/(foo)/ or $self->my_die( 'bar' );
print $1, "\n";

===
--- dscr: Failure to match causes transfer of control - RT 36081.
--- failures: 0
--- params:
--- input
m/(foo)/ or next;
print $1, "\n";
m/(foo)/ or last;
print $1, "\n";
m/(foo)/ or redo;
print $1, "\n";
m/(foo)/ or goto FOO;
print $1, "\n";
m/(foo)/ or return;
print $1, "\n";
m/(foo)/ || next;
print $1, "\n";
m/(foo)/ || last;
print $1, "\n";
m/(foo)/ || redo;
print $1, "\n";
m/(foo)/ || goto FOO;
print $1, "\n";
m/(foo)/ || return;
print $1, "\n";

===
--- dscr: Failure to match causes transfer of control (regex in outer block) - RT 36081.
--- failures: 0
--- params:
--- input
m/(foo)/ or return;
{
    print $1, "\n";
}

===
--- dscr: Failure to match causes transfer of control (regex in inner block) - RT 36081.
--- failures: 1
--- params:
--- input
{
    m/(foo)/ or return;
}
print $1, "\n";

===
--- dscr: Failure to match does not cause transfer of control (regex in inner block) - RT 36081.
--- failures: 1
--- params:
--- input
{
    m/(foo)/;
}
print $1, "\n";

===
--- dscr: goto that transfers around capture - RT 36081.
--- failures: 0
--- params:
--- input
{
    m/(foo)/ or goto BAR;
    print $1, "\n";
    BAR:
    print "Baz\n";
}

{
BAR: m/(foo)/ or goto BAR;
    print $1, "\n";
}

{
    m/(foo)/ or goto &bar;
    print $1, "\n";
}

===
--- dscr: regex in suffix control
--- failures: 0
--- params:
--- input
die unless m/(foo)/;
print $1, "\n";
last unless m/(foo)/;
print $1, "\n";
die "Arrrgh" unless m/(foo)/;
print $1, "\n";
die if m/(foo)/;
print $1, "\n";
last if m/(foo)/;
print $1, "\n";
die "Arrrgh" if m/(foo)/;
print $1, "\n";

===
--- dscr: regex in loop with capture in nested if
--- failures: 0
--- params:
--- input
foreach (qw{foo bar baz}) {
    next unless m/(foo)/;
    if ($1) {
        print "Foo!\n";
    }
}

===
--- dscr: regex in while, capture in loop
--- failures: 0
--- params:
--- input
while (m/(foo)/) {
    print $1, "\n";
}

===
--- dscr: Regex followed by "and do {...}" RT #50910
--- failures: 0
--- params:
--- input
m/^commit (.*)/xsm and do {
     $commit = $1;
     next;
};

===
--- dscr: regex inside when(){} RT #36081
--- failures: 0
--- params:
--- input
use 5.010;

given ( 'abc' ) {
    when ( m/(a)/ ) {
        say $1;
    }
}

# TODO
# ===
# --- dscr: goto that does not transfer around capture - RT 36081.
# --- failures: 1
# --- params:
# --- input
# {
#     m/(foo)/ or goto BAR;
# BAR : print $1, "\n";
# }

# ===
# --- dscr: goto that can not be disambiguated - RT 36081.
# --- failures: 1
# --- params:
# --- input
# {
# FOO: m/(foo)/ or goto (qw{FOO BAR BAZ})[$i];
# BAR: print $1, "\n";
# BAZ:
# }

