use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::RequireBracedFileHandleWithPrint;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::RequireBracedFileHandleWithPrint';

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
--- dscr: basic failures (print)
--- failures: 7
--- params:
--- input
#print $fh;           #Punt on this
#print $fh if 1;
print $fh "something" . "something else";
print $fh generate_report();
print $fh "something" if $DEBUG;
print $fh @list;
print $fh $foo, $bar;
print( $fh @list );
print( $fh $foo, $bar );

===
--- dscr: basic failures (printf)
--- failures: 7
--- params:
--- input
#printf $fh;           #Punt on this
#printf $fh if 1;
printf $fh "something" . "something else";
printf $fh generate_report();
printf $fh "something" if $DEBUG;
printf $fh @list;
printf $fh $foo, $bar;
printf( $fh @list );
printf( $fh $foo, $bar );

===
--- dscr: more arcane passes (print)
--- failures: 0
--- params:
--- input
print "something" . "something else";
print "something" . "something else"
  or die;
print {FH} "something" . "something else";
print {FH} "something" . "something else"
  or die;

print generate_report();
print generate_report()
  or die;
print {FH} generate_report();
print {FH} generate_report()
  or die;

print rand 10;
print rand 10
  or die;

print {FH};
print {FH}
  or die;
print {FH} @list;
print {FH} @list
  or die;
print {FH} $foo, $bar;
print {FH} $foo, $bar
  or die;

print @list;
print @list
  or die;
print $foo, $bar;
print $foo, $bar
  or die;
print $foo , $bar;
print $foo , $bar
  or die;
print foo => 1;
print foo => 1
  or die;

print( {FH} @list );
print( {FH} @list )
  or die;
print( {FH} $foo, $bar );
print( {FH} $foo, $bar )
  or die;

print();
print()
  or die;
print( );
print( )
  or die;
print( @list );
print( @list )
  or die;
print( $foo, $bar );
print( $foo, $bar )
  or die;

print if 1;
print or die if 1;

print 1 2; # syntax error, but not a policy violation
# $foo{print}; # not a function call
# {print}; # no siblings

===
--- dscr: more arcane passes (printf)
--- failures: 0
--- params:
--- input
printf "something" . "something else";
printf "something" . "something else"
  or die;
printf {FH} "something" . "something else";
printf {FH} "something" . "something else"
  or die;

printf generate_report();
printf generate_report()
  or die;
printf {FH} generate_report();
printf {FH} generate_report()
  or die;

printf rand 10;
printf rand 10
  or die;

printf {FH};
printf {FH}
  or die;
printf {FH} @list;
printf {FH} @list
  or die;
printf {FH} $foo, $bar;
printf {FH} $foo, $bar
  or die;

printf @list;
printf @list
  or die;
printf $foo, $bar;
printf $foo, $bar
  or die;
printf $foo , $bar;
printf $foo , $bar
  or die;
printf foo => 1;
printf foo => 1
  or die;

printf( {FH} @list );
printf( {FH} @list )
  or die;
printf( {FH} $foo, $bar );
printf( {FH} $foo, $bar )
  or die;

printf();
printf()
  or die;
printf( );
printf( )
  or die;
printf( @list );
printf( @list )
  or die;
printf( $foo, $bar );
printf( $foo, $bar )
  or die;

printf if 1;
printf or die if 1;

printf 1 2; # syntax error, but not a policy violation
$foo{printf}; # not a function call
{printf}; # no siblings

===
--- dscr: more bracing arcana (print)
--- failures: 0
--- params:
--- input
print {$fh};
print {$fh} @list;
print {$fh} $foo, $bar;
print( {$fh} @list );
print( {$fh} $foo, $bar );

===
--- dscr: more bracing arcana (printf)
--- failures: 0
--- params:
--- input
printf {$fh};
printf {$fh} @list;
printf {$fh} $foo, $bar;
printf( {$fh} @list );
printf( {$fh} $foo, $bar );

===
--- dscr: RT #49500: say violations
--- failures: 6
--- params:
--- input
say FH "foo";
# say $fh;              #Punt on this
say $fh "foo";
say $fh @list;
say $fh print_report();
say $fh "foo" or die;
say( $fh "foo" );

===
--- dscr: RT #49500: say compliances
--- failures: 0
--- params:
--- input
say { FH } "foo";
say { $fh };
say { $fh } "foo";
say { $fh } @list;
say { $fh } print_report();
say { $fh } "foo" or die;
say( { $fh } "foo" );

