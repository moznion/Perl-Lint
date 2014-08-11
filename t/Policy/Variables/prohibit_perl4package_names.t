use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitPerl4PackageNames;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitPerl4PackageNames';

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
--- dscr: Perl 4 package declarations
--- failures: 3
--- params:
--- input
package Foo'Bar;
package Foo::Bar'Baz;
package Foo'Bar::Baz;

===
--- dscr: Perl 5 package declarations
--- failures: 0
--- params:
--- input
package Foo;
package Foo::Bar;
package Foo::Bar::Baz;

===
--- dscr: Perl 4 simple variable access
--- failures: 9
--- params:
--- input
my $x = $Foo'bar;
my $x = $Foo'Bar::baz;
my $x = $Foo::Bar'baz;

my @x = @Foo'bar;
my @x = @Foo'Bar::baz;
my @x = @Foo::Bar'baz;

my %x = %Foo'bar;
my %x = %Foo'Bar::baz;
my %x = %Foo::Bar'baz;

===
--- dscr: Perl 5 simple variable access
--- failures: 0
--- params:
--- input
my $x = $Foo::bar;
my $x = $Foo::Bar::baz;

my @x = @Foo;
my @x = @Foo::bar;

my %x = %Foo::baz;
my %x = %Foo::Bar::baz;

===
--- dscr: Perl 4 simple variable assignment
--- failures: 9
--- params:
--- input
$Foo'bar       = $x;
$Foo'Bar::baz  = $x;
$Foo::Bar'baz  = $x;

@Foo'bar       = @x;
@Foo'Bar::baz  = @x;
@Foo::Bar'baz  = @x;

%Foo'bar       = %x;
%Foo'Bar::baz  = %x;
%Foo::Bar'baz  = %x;

===
--- dscr: Perl 4 localized variable assignment
--- failures: 11
--- params:
--- input
local $Foo'bar       = $x;
local $Foo'Bar::baz  = $x;
local $Foo::Bar'baz  = $x;

local @Foo'bar       = @x;
local @Foo'Bar::baz  = @x;
local @Foo::Bar'baz  = @x;

local %Foo'bar       = %x;
local %Foo'Bar::baz  = %x;
local %Foo::Bar'baz  = %x;

local ($Foo'Bar'baz, $Foo'Bar'bam) = @list;

===
--- dscr: Perl 5 simple variable assignment
--- failures: 0
--- params:
--- input
$Foo::Bar = $x;
$Foo::Bar::baz = $x;

@Foo::Bar = @x;
@Foo::Bar::baz = @x;

%Foo::Bar = %x;
%Foo::Bar::baz = %x;

===
--- dscr: Perl 5 localized variable assignment
--- failures: 0
--- params:
--- input
local $Foo::Bar = $x;
local $Foo::Bar::baz = $x;

local @Foo::Bar = @x;
local @Foo::Bar::baz = @x;

local %Foo::Bar = %x;
local %Foo::Bar::baz = %x;

local ($Foo::Bar::baz, $Foo::Bar::bam) = @list;

===
--- dscr: Perl 4 simple subroutine invocation
--- failures: 8
--- params:
--- input
Foo'bar();
&Foo'bar;
Foo'Bar::baz($x, 'y');
Foo::Bar'baz($x, 'y');

my $x = Foo'bar();
my $x = &Foo'bar;
my $x = Foo'Bar::baz($x, 'y');
my $x = Foo::Bar'baz($x, 'y');

===
--- dscr: Perl 5 simple subroutine invocation
--- failures: 0
--- params:
--- input
Foo::bar();
&Foo::bar;
Foo::Bar::baz($x, 'y');
my $x = Foo::bar();
my $x = &Foo::bar;
my $x = Foo::Bar::baz($x, 'y');

===
--- dscr: Perl 4 simple direct class method invocation
--- failures: 8
--- params:
--- input
Foo'bar->new();
&Foo'bar->new;
Foo'Bar::baz->new($x, 'y');
Foo::Bar'baz->new($x, 'y');

my $x = Foo'bar->new();
my $x = &Foo'bar->new;
my $x = Foo'Bar::baz->new($x, 'y');
my $x = Foo::Bar'baz->new($x, 'y');

===
--- dscr: Perl 5 simple direct class method invocation
--- failures: 0
--- params:
--- input
Foo::bar->new();
&Foo::bar->new;
Foo::Bar::baz->new($x, 'y');

my $x = &Foo::bar->new;
my $x = Foo::bar->new();
my $x = Foo::Bar::baz->new($x, 'y');

===
--- dscr: Perl 4 simple indirect class method invocation
--- failures: 4
--- params:
--- input
$z = new Foo'bar();
$z = new Foo'bar;
$z = new Foo'Bar::baz($x, 'y');
$z = new Foo::Bar'baz($x, 'y');

===
--- dscr: Perl 5 simple indirect class method invocation
--- failures: 0
--- params:
--- input
$z = new Foo::bar();
$z = new Foo::bar;
$z = new Foo::Bar::baz($x, 'y');

===
--- dscr: complicated statements
--- failures: 20
--- params:
--- input
# If PPI ever gains the ability to parse regexes failures ought to be 26.
@Foo::bar = Xyzzy::Qux::corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo'bar = Xyzzy::Qux::corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy'Qux::corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy::Qux'corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy::Qux::corge(Grault'Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy::Qux::corge(Grault::Thud->fred('x') + new Plugh'Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy::Qux::corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B'C::d e /xms;
@Foo::bar = Xyzzy::Qux::corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C'd e /xms;

@Foo'bar = Xyzzy::Qux'corge(Grault::Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy'Qux::corge(Grault'Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy::Qux'corge(Grault::Thud->fred('x') + new Plugh'Waldo) =~ m/ a $B::C::d e /xms;
@Foo::bar = Xyzzy::Qux::corge(Grault'Thud->fred('x') + new Plugh::Waldo) =~ m/ a $B'C::d e /xms;
@Foo::bar = Xyzzy::Qux::corge(Grault::Thud->fred('x') + new Plugh'Waldo) =~ m/ a $B::C'd e /xms;

@Foo'bar = Xyzzy::Qux'corge(Grault::Thud->fred('x') + new Plugh'Waldo) =~ m/ a $B'C::d e /xms;

@Foo'bar = Xyzzy'Qux'corge(Grault'Thud->fred('x') + new Plugh'Waldo) =~ m/ a $B'C'd e /xms;

===
--- dscr: hash keys
--- failures: 0
--- params:
--- input
$foo = { bar'baz => 0 };
print $foo{ bar'baz };

===
--- dscr: $POSTMATCH
--- failures: 0
--- params:
--- input
$foo = $';
print $';

@foo = @';
%foo = %';
$foo = \&';
*foo = *';

