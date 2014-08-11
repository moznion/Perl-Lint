use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitCommaSeparatedStatements;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitCommaSeparatedStatements';

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
@x = (@y, @z);
my $expl = [133, 138];
$lookup = { a => 1, b => 2 };

===
--- dscr: Basic failure
--- failures: 1
--- params:
--- input
@x = @y, @z;

===
--- dscr: List including assignments
--- failures: 0
--- params:
--- input
@w = ($x = 1, $y = 2, $z = 3);

===
--- dscr: List containing statement
--- failures: 0
--- params:
--- input
@w = ( {}, [] );

===
--- dscr: List containing statement in a constructor that is reported as a block
--- failures: 0
--- params:
--- input
my %foo = (
    blah => {
        blah => 'blah',
    },
);

===
--- dscr: Regular statement inside a block.
--- failures: 0
--- params:
--- input
foreach my $path ( @ARGV ) {
    utter 'Looking at ', $path, '.';
}

===
--- dscr: Sub call after comma
--- failures: 1
--- params:
--- input
@x = @y, foo @z;

===
--- dscr: Regular sub call before comma
--- failures: 1
--- params:
--- input
# The space between the sub name and the left parenthesis is significant
# in that part of Conway's point is that things that look like lists may
# not be.

@x = foo (@y), @z;

===
--- dscr: No-argument sub call via use of sigil
--- failures: 1
--- params:
--- input
@x = &foo, @y, bar @z;

===
--- dscr: Two sub calls
--- failures: 0
--- params:
--- input
@x = foo @y, bar @z;

===
--- dscr: Built-in call that provides a list context without parentheses
--- failures: 0
--- params:
--- input
@x = push @y, @z;

===
--- dscr: Built-in call that provides a list context, called like a function
--- failures: 1
--- params:
--- input
@x = push (@y), @z;

===
--- dscr: Built-in call that takes multiple arguments without parentheses
--- failures: 0
--- params:
--- input
@x = substr $y, 1, 2;

===
--- dscr: Built-in call that takes multiple arguments, called like a function
--- failures: 1
--- params:
--- input
@x = substr ($y, 1), 2;

===
--- dscr: Call to unary built-in without parentheses
--- failures: 1
--- params:
--- input
@x = tied @y, @z;

===
--- dscr: Unary built-in, called like a function
--- failures: 1
--- params:
--- input
@x = tied (@y), @z;

===
--- dscr: Call to no-argument built-in without parentheses
--- failures: 1
--- params:
--- input
@x = time, @z;

===
--- dscr: No-argument built-in, called like a function
--- failures: 1
--- params:
--- input
@x = time (), @z;

===
--- dscr: Call to optional argument built-in without an argument without parentheses
--- failures: 1
--- params:
--- input
@x = sin, @z;

===
--- dscr: Optional argument built-in, called like a function without an argument
--- failures: 1
--- params:
--- input
@x = sin (), @z;

===
--- dscr: Call to optional argument built-in with an argument without parentheses
--- failures: 1
--- params:
--- input
@x = sin @y, @z;

===
--- dscr: Optional argument built-in, called like a function with an argument
--- failures: 1
--- params:
--- input
@x = sin (@y), @z;

===
--- dscr: For loop
--- failures: 2
--- params:
--- input
for ($x = 0, $y = 0; $x < 10; $x++, $y += 2) {
    foo($x, $y);
}

===
--- dscr: For loop
--- failures: 0
--- params:
--- input
for ($x, 'x', @y, 1, ) {
    print;
}

===
--- dscr: qw<>
--- failures: 0
--- params:
--- input
@list = qw<1, 2, 3>; # this really means @list = ('1,', '2,', '3');

===
--- dscr: original RT #27654
--- failures: 0
--- params:
--- input
my @arr1;
@arr1 = split /b/, 'abc';

===
--- dscr: RT #27654 - NKH example 1
--- failures: 0
--- params:
--- input
return
  {
  "string" => $aliased_history,
  TIME => $self->{something},
  } ;

===
--- dscr: RT #27654 - NKH example 2 - without allow_last_statement_to_be_comma_separated_in_map_and_grep
--- failures: 2
--- params:
--- input
%hash = map {$_, 1} @list ;
%hash = grep {$_, 1} @list ;

===
--- dscr: RT #27654 - NKH example 2 - with allow_last_statement_to_be_comma_separated_in_map_and_grep
--- failures: 0
--- params: {prohibit_comma_separated_statements => {allow_last_statement_to_be_comma_separated_in_map_and_grep => 1}}
--- input
%hash = map {$_, 1} @list ;
%hash = grep {$_, 1} @list ;

===
--- dscr: RT #27654 - NKH example 3
--- failures: 0
--- params:
--- input
## TODO PPI parses this code as blocks and not hash constructors.
$self->DoSomething
  (
  { %{$a_hash_ref}, %{$another_hash_ref}},
  @more_data,
  ) ;

===
--- dscr: RT #33935 and 49679
--- failures: 0
--- params:
--- input
func( @{ $href }{'1', '2'} );

===
--- dscr: RT #61301 (requires PPI 1.215)
--- failures: 0
--- params:
--- input
sub foo {
    return { bar => 1, answer => 42 };
}

===
--- dscr: RT #64132 (requires PPI 1.215)
--- failures: 0
--- params:
--- input
sub new {
    return bless { foo => 1, bar => 2 }, __PACKAGE__;
}

