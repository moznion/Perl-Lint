use strict;
use warnings;
use Perl::Lint::Policy::Variables::ProhibitUnusedVariables;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitUnusedVariables';

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
--- dscr: Simple unused, single, unassigned lexical.
--- failures: 1
--- params:
--- input
my $x;

===
--- dscr: Simple unused, multiple, unassigned lexicals.
--- failures: 3
--- params:
--- input
my ($x, @z, %y);

===
--- dscr: Simple unused assigned lexicals.  Not going to handle this yet.
--- failures: 0
--- params:
--- input
# Need to look out for RAII.
my $y = foo();

===
--- dscr: List assignment.  Not going to handle this yet.
--- failures: 0
--- params:
--- input
sub foo {
    my ($b, $y) = @_;
}

===
--- dscr: Simple unused explicit global.
--- failures: 0
--- params:
--- input
our $x;

===
--- dscr: Simple unused implicit global.
--- failures: 0
--- params:
--- input
$x;

===
--- dscr: Simple unused localized.
--- failures: 0
--- params:
--- input
local $x;

===
--- dscr: Simple used lexical scalar.
--- failures: 0
--- params:
--- input
my $x = 1;

print $x;

===
--- dscr: Simple used lexical array.
--- failures: 0
--- params:
--- input
my @x;

$x[0] = 5;

===
--- dscr: Simple used lexical hash.
--- failures: 0
--- params:
--- input
my %foo;

$foo{bar} = -24;

===
--- dscr: Shadowed variable.  No going to handle this yet.
--- failures: 0
--- params:
--- input
my $x = 2;

{
    my $x = 1;
    blah();
}

===
--- dscr: Separate lexicals.  No going to handle this yet.
--- failures: 0
--- params:
--- input
{
    my $x = 2;
}

{
    my $x = 1;
    blah();
}

===
--- dscr: Closures
--- failures: 0
--- params:
--- input
{
   my $has_graphviz = undef;

   sub has_graphviz {
      if (!defined $has_graphviz) {
         $has_graphviz = eval { require GraphViz; 1; } ? 1 : 0;
      }
      return $has_graphviz;
   }
}

===
--- dscr: Interpolation in replacement portion of s/.../.../smx
--- failures: 0
--- params:
--- input
my %foo;

s/ ( \w+ ) /$foo{$1}/smx;

===
--- dscr: Interpolation in replacement portion of s/.../.../smxe
--- failures: 0
--- params:
--- input
my %foo;

s/ ( \w+ ) / $foo{$1} /smxe;

===
--- dscr: Variable used in regexp embedded code
--- failures: 0
--- params:
--- input
my %foo;

m/ (?{ $foo{bar} }) /smx;

