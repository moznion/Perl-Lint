use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitUnusedCapture;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitUnusedCapture';

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
--- dscr: non-captures
--- failures: 0
--- params:
--- input
m/foo/;
m/(?:foo)/;

if (m/foo/) {
   print "bar";
}

===
--- dscr: assignment captures
--- failures: 0
--- params:
--- input
my ($foo) = m/(foo)/;
my ($foo) = m/(foo|bar)/;
my ($foo) = m/(foo)(?:bar)/;
my @foo = m/(foo)/;
my @foo = m/(foo)/g;
my %foo = m/(foo)(bar)/g;

my ($foo, $bar) = m/(foo)(bar)/;
my @foo = m/(foo)(bar)/;
my ($foo, @bar) = m/(foo)(bar)/;
my ($foo, @bar) = m/(foo)(bar)(baz)/;

===
--- dscr: undef array captures
--- failures: 0
--- params:
--- input
() = m/(foo)/;
(undef) = m/(foo)/;
my ($foo) =()= m/(foo)/g;

===
--- dscr: complex array assignment captures
--- failures: 0
--- params:
--- input
@$foo = m/(foo)(bar)/;
@{$foo} = m/(foo)(bar)/;
%$foo = m/(foo)(bar)/;
%{$foo} = m/(foo)(bar)/;

($foo,@$foo) = m/(foo)(bar)/;
($foo,@{$foo}) = m/(foo)(bar)/;

===
--- dscr: conditional captures
--- failures: 0
--- params:
--- input
if (m/(foo)/) {
   my $foo = $1;
   print $foo;
}
if (m/(foo)(bar)/) {
   my $foo = $1;
   my $bar = $2;
   print $foo, $bar;
}
if (m/(foo)(bar)/) {
   my ($foo, $bar) = ($1, $2);
   print $foo, $bar;
}
if (m/(foo)(bar)/) {
   my (@foo) = ($1, $2);
   print @foo;
}

if (m/(foo)/) {
   # bug, but not a violation of THIS policy
   my (@foo) = ($1, $2);
   print @foo;
}

===
--- dscr: RT #38942
--- failures: 0
--- params:
--- input
while ( pos() < length ) {
    m{\G(a)(b)(c)}gcxs or die;
    my ($a, $b, $c) = ($1, $2, $3);
}

===
--- dscr: boolean and ternary captures
--- failures: 0
--- params:
--- input
m/(foo)/ && print $1;
m/(foo)/ ? print $1 : die;
m/(foo)/ && ($1 == 'foo') ? print 1 : die;

===
--- dscr: loop captures
--- failures: 0
--- params:
--- input
for (m/(foo)/) {
   my $foo = $1;
   print $foo;
}

===
--- dscr: slurpy array loop captures
--- failures: 0
--- params:
--- input
map {print} m/(foo)/;
foo(m/(foo)/);
foo('bar', m/(foo)/);
foo(m/(foo)/, 'bar');
foo m/(foo)/;
foo 'bar', m/(foo)/;
foo m/(foo)/, 'bar';

===
--- dscr: slurpy with assignment
--- failures: 0
--- params:
--- input
my ($foo) = grep {$b++ == 2} m/(foo)/g;
my ($foo) = grep {$b++ == 2} $str =~ m/(foo)/g;

===
--- dscr: slurpy with array assignment
--- failures: 0
--- params:
--- input
my @foo = grep {$b++ > 2} m/(foo)/g;
my @foo = grep {$b++ > 2} $str =~ m/(foo)/g;

===
--- dscr: assignment captures on string
--- failures: 0
--- params:
--- input
my ($foo) = $str =~ m/(foo)/;
my ($foo) = $str =~ m/(foo|bar)/;
my ($foo) = $str =~ m/(foo)(?:bar)/;
my @foo = $str =~ m/(foo)/;
my @foo = $str =~ m/(foo)/g;

my ($foo, $bar) = $str =~ m/(foo)(bar)/;
my @foo = $str =~ m/(foo)(bar)/;
my ($foo, @bar) = $str =~ m/(foo)(bar)/;
my (@bar) = $str =~ m/(foo)(bar)/;
my ($foo, @bar) = $str =~ m/(foo)(bar)(baz)/;

===
--- dscr: slurpy captures on string
--- failures: 0
--- params:
--- input
map {print} $str =~ m/(foo)/g;

===
--- dscr: self captures
--- failures: 0
--- params:
--- input
m/(foo)\1/;
s/(foo)/$1/;
s/(foo)/\1/;
s<\A t[\\/] (\w+) [\\/] (\w+) [.]run \z><$1\::$2>xms

===
--- dscr: q{} should be ignored
--- failures: 0
--- params:
--- input
q/(foo)/;
my ($foo) = q/(foo)/g;

if (q/(foo)/) {
   print "bar";
}
if (q/(foo)(bar)/) {
   my $foo = $1;
   print $foo;
}

for (q/(foo)/) {
   print "bar";
}

===
--- dscr: qq{} should be ignored
--- failures: 0
--- params:
--- input
qq/(foo)/;
my ($foo) = qq/(foo)/g;

if (qq/(foo)/) {
   print "bar";
}
if (qq/(foo)(bar)/) {
   my $foo = $1;
   print $foo;
}

for (qq/(foo)/) {
   print "bar";
}

===
--- dscr: qx{} should be ignored
--- failures: 0
--- params:
--- input
qx/(foo)/;
my ($foo) = qx/(foo)/g;

if (qx/(foo)/) {
   print "bar";
}
if (qx/(foo)(bar)/) {
   my $foo = $1;
   print $foo;
}

for (qx/(foo)/) {
   print "bar";
}

===
--- dscr: qw{} should be ignored
--- failures: 0
--- params:
--- input
qw/(foo)/;
my ($foo) = qw/(foo)/g;

if (qw/(foo)/) {
   print "bar";
}
if (qw/(foo)(bar)/) {
   my $foo = $1;
   print $foo;
}

for (qw/(foo)/) {
   print "bar";
}


===
--- dscr: basic failures
--- failures: 5
--- params:
--- input
m/(foo)/;
my ($foo) = m/(foo)/g;

if (m/(foo)/) {
   print "bar";
}
if (m/(foo)(bar)/) {
   my $foo = $1;
   print $foo;
}

for (m/(foo)/) {
   print "bar";
}

===
--- dscr: negated regexp failures
--- failures: 1
--- params:
--- input
my ($foo) = $str !~ m/(foo)/;

===
--- dscr: statement failures
--- failures: 1
--- params:
--- input
m/(foo)/ && m/(bar)/ && print $1;

===
--- dscr: sub failures
--- failures: 1
--- params:
--- input
sub foo {
  m/(foo)/;
  return;
}
print $1;

===
--- dscr: anon sub failures
--- failures: 1
--- params:
--- input
## TODO PPI v1.118 doesn't recognize anonymous subroutines
my $sub = sub foo {
  m/(foo)/;
  return;
};
print $1;

===
--- dscr: ref constructors
--- failures: 0
--- params:
--- input
$f = { m/(\w+)=(\w+)/g };
$f = [ m/(\w+)/g ];

===
--- dscr: sub returns
--- failures: 0
--- params:
--- input
sub foo {
   m/(foo)/;
}
sub foo {
   return m/(foo)/;
}
map { m/(foo)/ } (1, 2, 3);

## NOTE: ignore
# ===
# --- dscr: failing regexp with syntax error
# --- failures: 0
# --- params:
# --- input
# m/(foo)(/;

===
--- dscr: lvalue sub assigment pass
--- failures: 0
--- params:
--- input
(substr $str, 0, 1) = m/(\w+)/;

## TODO lvalue subs are too complex to support
# ===
# --- dscr: lvalue sub assigment failure
# --- failures: 1
# --- params:
# --- input
# (substr $str, 0, 1) = m/(\w+)(\d+)/;

===
--- dscr: code coverage
--- failures: 1
--- params:
--- input
m/(foo)/;
print $0;
print @ARGV;
print $_;

===
--- dscr: while loop with /g
--- failures: 0
--- params:
--- input
while (m/(\d+)/g) {
    print $1, "\n";
}

===
--- dscr: conditional named captures
--- failures: 0
--- params:
--- input
if ( m/(?<foo>bar)/ ) {
    print $+{foo}, "\n";
}

while ( m/(?'foo'\d+)/g ) {
    print $-{foo}[0], "\n";
}

m/(?P<foo>\w+)|(?<foo>\W+)/ and print $+{foo}, "\n";

===
--- dscr: named capture in array context is unused
--- failures: 2
--- params:
--- input
my @foo = m/(?<foo>\w+)/;
sub foo {
    return m/(?<foo>\W+)/;
}

===
--- dscr: named capture in array context with siblings is OK
--- failures: 0
--- params:
--- input
my @foo = m/(?<foo>\w+)/;
print $+{foo}, "\n";

===
--- dscr: named capture not used in replacement
--- failures: 1
--- params:
--- input
s/(?<foo>\w+)/foo$1/g;

===
--- dscr: named capture used in replacement
--- failures: 0
--- params:
--- input
s/(?<foo>\w+)/foo$+{foo}/g;

===
--- dscr: subscripted capture
--- failures: 0
--- params:
--- input
s/(foo)/$+[ 1 ]/;
s/(foo)/$-[ 1 ]/;
s/(foo)/$+[ -1 ]/;
s/(foo)/$-[ -1 ]/;
m/(\w+)/ and print substr( $_, $-[ 1 ], $+[ 1 ] - $-[ 1 ] );
m/(\w+)/ and print substr( $_, $-[ -1 ], $+[ -1 ] - $-[ -1 ] );

===
--- dscr: named capture English name in replacement RT #60002
--- failures: 1
--- params:
--- input
s/(?<foo>\w+)/foo$LAST_PAREN_MATCH{foo}/g;

===
--- dscr: named capture English name in code RT #60002
--- failures: 1
--- params:
--- input

m/(?P<foo>\w+)|(?<foo>\W+)/ and print $LAST_PAREN_MATCH{foo}, "\n";

===
--- dscr: named capture English name in replacement RT #60002
--- failures: 0
--- params:
--- input
use English;

s/(?<foo>\w+)/foo$LAST_PAREN_MATCH{foo}/g;

===
--- dscr: named capture English name in code RT #60002
--- failures: 0
--- params:
--- input
use English;

m/(?P<foo>\w+)|(?<foo>\W+)/ and print $LAST_PAREN_MATCH{foo}, "\n";

===
--- dscr: English subscripted capture without use English
--- failures: 6
--- params:
--- input
s/(foo)/$LAST_MATCH_END[ 1 ]/;
s/(foo)/$LAST_MATCH_START[ 1 ]/;
s/(foo)/$LAST_MATCH_END[ -1 ]/;
s/(foo)/$LAST_MATCH_START[ -1 ]/;
m/(\w+)/ and print substr(
    $_, $LAST_MATCH_START[ 1 ], $LAST_MATCH_END[ 1 ] - $LAST_MATCH_START[ 1 ] );
m/(\w+)/ and print substr(
    $_, $LAST_MATCH_START[ -1 ],
    $LAST_MATCH_END[ -1 ] - $LAST_MATCH_START[ -1 ] );

===
--- dscr: English subscripted capture with use English
--- failures: 0
--- params:
--- input
use English;

s/(foo)/$LAST_MATCH_END[ 1 ]/;
s/(foo)/$LAST_MATCH_START[ 1 ]/;
s/(foo)/$LAST_MATCH_END[ -1 ]/;
s/(foo)/$LAST_MATCH_START[ -1 ]/;
m/(\w+)/ and print substr(
    $_, $LAST_MATCH_START[ 1 ], $LAST_MATCH_END[ 1 ] - $LAST_MATCH_START[ 1 ] );
m/(\w+)/ and print substr(
    $_, $LAST_MATCH_START[ -1 ],
    $LAST_MATCH_END[ -1 ] - $LAST_MATCH_START[ -1 ] );

===
--- dscr: Capture used in substitution portion of s/.../.../e
--- failures: 0
--- params:
--- input
s/(\w+)/$replace{$1} || "<$1>"/ge;

===
--- dscr: Capture used in double-quotish string. RT #38942 redux
--- failures: 0
--- params:
--- input
m/(\w+)(\W+)/;
print "$+[2] $1";

m/(?<foo>\w+)/;
print "$+{foo}";

m/(\d+)/;
print "${1}234";

===
--- dscr: Capture used in a here document. RT #38942 redux
--- failures: 0
--- params:
--- input
m/(\w+)(\W+)/;
print <<EOD
$+[2] $1
EOD

===
--- dscr: Alternation. RT #38942 redux
--- failures: 0
--- params:
--- input
if ( /(a)/ || /(b)/ ) {
    say $1;
}

# Yes, this is incorrect code, but that's ProhibitCaptureWithoutTest's
# problem.
if ( /(a)/ // /(b)/ ) {
    say $1;
}

# Contrived, but worse things happen at sea.
if ( ( /(a)/ || undef ) // /(b)/ ) {
    say $1;
}

if ( /(a)/ or /(b)/ ) {
    say $1;
}

===
--- dscr: Alternation with conjunction. RT #38942 redux
--- failures: 3
--- params:
--- input
# 1 failure here: the /(b)/
if ( /(a)/ || /(b)/ && /(c)/ ) {
    say $1;
}

# 1 failure here: the /(b)/
if ( /(a)/ or /(b)/ and /(c)/ ) {
    say $1;
}

# 2 failures here: the /(a)/ and the /(b)/
# NOTE: but handling 1 failure by Perl::Lint
if ( /(a)/ || /(b)/ and /(c)/ ) {
    say $1;
}

===
--- dscr: RT #67116 - Incorrect check of here document.
--- failures: 1
--- params:
--- input
$x !~ /()/;
<<X;
.
.
.
X

===
--- dscr: RT #69867 - Incorrect check of if() statement if regexp negated
--- failures: 0
--- params:
--- input
if ( $ip !~ /^(.*?)::(.*)\z/sx ) {
    @fields = split /:/x, $ip;
} else {
    my ( $before, $after ) = ( $1, $2 );
}

===
--- dscr: RT #72086 - False positive with /e and parens
--- failures: 0
--- params:
--- input
s/(.)/($1)/e;
s/(.)/ { $1 } /e;

