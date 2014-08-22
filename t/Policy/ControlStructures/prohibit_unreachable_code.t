use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitUnreachableCode;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitUnreachableCode';

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
sub a {
  return 123 if $a == 1;
  do_something();
}

sub b {
  croak 'error' unless $b;
  do_something();
}

sub c {
  confess 'error' if $c != $d;
  do_something();
}

for (1..2) {
  next if $_ == 1;
  do_something();
}

for (1..2) {
  last if $_ == 2;
  do_something();
}

for (1..2) {
  redo if do_this($_);
  do_something();
}

{
    exit;
    FOO:
    do_something();
}

{
    die;
    BAR:
    do_something();
}

{
    exit;
    sub d {}
    BAZ:
    print 123;
}

{
    die;
    JAPH:
    sub e {}
    print 456;
}

{
    exit;
    BEGIN {
        print 123;
    }
}

{
   $foo || die;
   print 123;
}

{
   $foo && die;
   print 123;
}

{
   $foo or die;
   print 123;
}

{
   $foo and die;
   print 123;
}

===
--- dscr: Basic failure
--- failures: 12
--- params:
--- input
{
    exit;
    require Foo;
}

sub a {
  return 123;
  do_something();
}

sub b {
  croak 'error';
  do_something();
}

sub c {
  confess 'error';
  do_something();
}

for (1..2) {
  next;
  do_something();
}

for (1..2) {
  last;
  do_something();
}

for (1..2) {
  redo;
  do_something();
}

{
    exit;
    do_something();
}


{
    die;
    do_something();
}


{
    exit;
    sub d {}
    print 123;
}

{
   $foo, die;
   print 123;
}

die;
print 456;
FOO: print $baz;

===
--- dscr: Compile-time code
--- failures: 0
--- params:
--- input
exit;

no warnings;
use Memoize;
our %memoization;

===
--- dscr: __DATA__ section
--- failures: 0
--- params:
--- input
exit;

__DATA__
...

===
--- dscr: __END__ section
--- failures: 0
--- params:
--- input
exit;

__END__
...

===
--- dscr: RT #36080
--- failures: 0
--- params:
--- input
my $home = $ENV{HOME} // die "HOME not set";
say 'hello';

===
--- dscr: RT #41734
--- failures: 0
--- params:
--- input
Foo::foo();
exit 0;

package Foo;
sub foo { print "hello\n"; }

===
--- dscr: failure with exiting statement twice
--- failures: 1
--- params:
--- input
{
    exit;
    exit;
}

