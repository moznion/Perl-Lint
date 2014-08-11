use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::RequireCheckedClose;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::RequireCheckedClose';

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
use Fatal "close";
close $filehandle;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal ('close');
close $filehandle;

===
--- dscr: Fatal.pm on
--- failures: 0
--- params:
--- input
use Fatal ("close");
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

