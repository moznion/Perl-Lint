use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::RequireCheckedSyscalls;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::RequireCheckedSyscalls';

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
--- dscr: passes by assigning error variable
--- failures: 0
--- params:
--- input
my $error = open( $filehandle, $mode, $filename );
my $error = open  $filehandle, $mode, $filename;
my $error = open  OPEN, $open, 'open';
my $error = open  OR, $or, 'or';

===
--- dscr: passes by "or die"
--- failures: 0
--- params:
--- input
open  $filehandle, $mode, $filename   or die 'could not open';
open( $filehandle, $mode, $filename ) or die 'could not open';
open( $filehandle, $mode, $filename ) or croak 'could not open';

===
--- dscr: passes by "|| die"
--- failures: 0
--- params:
--- input
open  $filehandle, $mode, $filename   or die 'could not open';
open( $filehandle, $mode, $filename ) || die 'could not open';
open( $filehandle, $mode, $filename ) || croak 'could not open';

===
--- dscr: passes by "unless"
--- failures: 0
--- params:
--- input
die unless open( $filehandle, $mode, $filename );
die unless open  $filehandle, $mode, $filename;

croak unless open( $filehandle, $mode, $filename );
croak unless open  $filehandle, $mode, $filename;

===
--- dscr: passes by "if not"
--- failures: 0
--- params:
--- input
die if not open( $filehandle, $mode, $filename );
die if not open  $filehandle, $mode, $filename;

croak if not open( $filehandle, $mode, $filename );
croak if not open  $filehandle, $mode, $filename;

die if !open( $filehandle, $mode, $filename );
die if !open  $filehandle, $mode, $filename;

croak if !open( $filehandle, $mode, $filename );
croak if !open  $filehandle, $mode, $filename;

===
--- dscr: passes with "if" statement
--- failures: 0
--- params:
--- input
if ( open( $filehandle, $mode, $filename ) ) { dosomething(); };

===
--- dscr: Basic failure with parens
--- failures: 2
--- params:
--- input
open( $filehandle, $mode, $filename );
open( $filehandle, $filename );

===
--- dscr: Basic failure no parens
--- failures: 2
--- params:
--- input
open $filehandle, $mode, $filename;
open $filehandle, $filename;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal qw(open);
open $filehandle, $filename;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal 'open';
open $filehandle, $filename;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal ('open');
open $filehandle, $filename;

===
--- dscr: Fatal::Exception on
--- failures: 0
--- params:
--- input
use Fatal::Exception 'Exception' => qw(open);
open $filehandle, $filename;

===
--- dscr: Fatal.pm off
--- failures: 1
--- params:
--- input
use Fatal qw(close);
open $filehandle, $filename;

===
--- dscr: passes by assigning error variable
--- failures: 0
--- params:
--- input
my $error = close( $filehandle );
my $error = close  $filehandle;
my $error = close  CLOSE;
my $error = close  OR;

===
--- dscr: passes by "or die"
--- failures: 0
--- params:
--- input
close  $filehandle  or die 'could not close';
close ($filehandle) or die 'could not close';
close ($filehandle) or croak 'could not close';

===
--- dscr: passes by "|| die"
--- failures: 0
--- params:
--- input
close  $filehandle  || die 'could not close';
close ($filehandle) || die 'could not close';
close ($filehandle) || croak 'could not close';

===
--- dscr: passes by "unless"
--- failures: 0
--- params:
--- input
die unless close ( $filehandle );
die unless close   $filehandle;

croak unless close ( $filehandle );
croak unless close   $filehandle;

===
--- dscr: passes by "if not"
--- failures: 0
--- params:
--- input
die if not close ( $filehandle );
die if not close   $filehandle;

croak if not close ( $filehandle );
croak if not close   $filehandle;

die if !close ( $filehandle );
die if !close   $filehandle;

croak if !close ( $filehandle );
croak if !close   $filehandle;

===
--- dscr: passes with "if" statement
--- failures: 0
--- params:
--- input
if ( close $filehandle ) { dosomething(); };

===
--- dscr: Basic failure with parens
--- failures: 1
--- params:
--- input
close( $filehandle );

===
--- dscr: Basic failure no parens
--- failures: 1
--- params:
--- input
close $filehandle;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal qw(close);
close $filehandle;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal 'close';
close $filehandle;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal ('close');
close $filehandle;

===
--- dscr: Fatal::Exception on
--- failures: 0
--- params:
--- input
use Fatal::Exception 'Exception' => qw(close);
close $filehandle;

===
--- dscr: Fatal.pm off
--- failures: 1
--- params:
--- input
use Fatal qw(open);
close $filehandle;

===
--- dscr: autodie on via no parameters
--- failures: 0
--- params:
--- input
use autodie;
close $filehandle;

===
--- dscr: autodie on via :io
--- failures: 0
--- params:
--- input
use autodie qw< :io >;
close $filehandle;

===
--- dscr: autodie off
--- failures: 1
--- params:
--- input
use autodie qw< :system >;
close $filehandle;

===
--- dscr: autodie on and off
--- failures: 1
--- params:
--- input
use autodie;
{
    no autodie;

    close $filehandle;
}

===
--- dscr: no config
--- failures: 0
--- params:
--- input
accept NEWSOCK, SOCKET;

===
--- dscr: config with single function
--- failures: 1
--- params: {require_checked_syscalls => {functions => 'accept'}}
--- input
accept NEWSOCK, SOCKET;

===
--- dscr: config with :builtins
--- failures: 1
--- params: {require_checked_syscalls => {functions => ':builtins'}}
--- input
accept NEWSOCK, SOCKET;

===
--- dscr: config with :builtins except print with failure
--- failures: 1
--- params: {require_checked_syscalls => {functions => ':builtins', exclude_functions => 'print'}}
--- input
accept NEWSOCK, SOCKET;

===
--- dscr: config with :builtins except print with failure
--- failures: 0
--- params: {require_checked_syscalls => {functions => ':builtins', exclude_functions => 'print'}}
--- input
print 'Foo!';

===
--- dscr: insane config with failures
--- failures: 2
--- params: {require_checked_syscalls => {functions => ':all'}}
--- input
sub foo {
  return 1;
}
foo();

===
--- dscr: insane config without failures
--- failures: 0
--- params: {require_checked_syscalls => {functions => ':all'}}
--- input
sub foo {
  return 1 or die;
}
foo() or die;

===
--- dscr: insane config with excluded function
--- failures: 0
--- params: {require_checked_syscalls => {functions => ':all', exclude_functions => 'foo'}}
--- input

foo();

===
--- dscr: RT #37487 - complain about use of say
--- failures: 1
--- params:
--- input
say 'The sun is a mass of incandessent gas';

