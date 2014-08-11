use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::ProhibitManyArgs;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::ProhibitManyArgs';

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
--- dscr: basic passes
--- failures: 0
--- params:
--- input
sub forward;

sub foo {
   my ($self, $bar) = @_;
}

sub fu {
   my $self = shift;
   my $bar = shift;
}

sub foo($$) {
   print $_[0];
   return;
}

===
--- dscr: simple failures
--- failures: 3
--- params:
--- input
sub foo {
   my ($self, $bar1, $bar2, $bar3, $bar4, $bar5) = @_;
}

sub fu {
   my $self = shift;
   my $bar1 = shift;
   my $bar2 = shift;
   my $bar3 = shift;
   my $bar4 = shift;
   my $bar5 = shift;
}

sub foo($$$$$$) {
   print $_[0];
   return;
}

===
--- dscr: configured failures
--- failures: 3
--- params: {prohibit_many_args => {max_arguments => 3}}
--- input
sub foo {
   my ($self, $bar1, $bar2, $bar3) = @_;
}

sub fu {
   my $self = shift;
   my $bar1 = shift;
   my $bar2 = shift;
   my $bar3 = shift;
}

sub foo($$$$) {
   print $_[0];
   return;
}

===
--- dscr: configured successes
--- failures: 0
--- params: {prohibit_many_args => {max_arguments => 3}}
--- input
sub foo_ok {
   my ($self, $bar1, $bar2) = @_;
}

sub fu_ok {
   my $self = shift;
   my $bar1 = shift;
   my $bar2 = shift;
}

sub foo_ok($$$) {
   print $_[0];
   return;
}

===
--- dscr: RT56627: prototype interpretation
--- failures: 0
--- params: {prohibit_many_args => {max_arguments => 3}}
--- input
sub foo ($;$) { return 1 }
sub bar ( $ ; $ ) { return 1 }

===
--- dscr: prototype grouping
--- failures: 0
--- params: {prohibit_many_args => {max_arguments => 3}}
--- input
sub foo (\[$@%]@) { return 1 }
sub bar ( \[$@%] $ \[$@%] ) { return 1 }

===
--- dscr: single term prototype (Perl 5.14)
--- failures: 0
--- params: {prohibit_many_args => {max_arguments => 2}}
--- input
sub foo ($+) { return 1 }

===
--- dscr: single term prototype (Perl 5.14)
--- failures: 1
--- params: {prohibit_many_args => {max_arguments => 2}}
--- input
sub foo ($$+) { return 1 }

