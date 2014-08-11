use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::RequireCheckedOpen;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::RequireCheckedOpen';

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
--- dscr: autodie on via no parameters
--- failures: 0
--- params:
--- input
use autodie;
open $filehandle;

===
--- dscr: autodie on via :io
--- failures: 0
--- params:
--- input
use autodie qw< :io >;
open $filehandle;

===
--- dscr: autodie off
--- failures: 1
--- params:
--- input
use autodie qw< :system >;
open $filehandle;

===
--- dscr: autodie on and off
--- failures: 1
--- params:
--- input
use autodie;
{
    no autodie;

    open $filehandle;
}

