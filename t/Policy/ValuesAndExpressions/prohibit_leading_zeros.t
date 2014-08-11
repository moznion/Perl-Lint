use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitLeadingZeros;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitLeadingZeros';

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
$var = 0;
$var = 0.;
$var = .0;
$var = 10;
$var = 0.0;
$var = 00.0;
$var = 00;
$var = 0.11;
$var = 10.0;
$var = -0;
$var = -0.;
$var = -10;
$var = -0.0;
$var = -10.0
$var = -0.11;
$var = +0;
$var = +0.;
$var = +10;
$var = +0.0;
$var = +10.0;
$var = +0.11;
$var = +.011;
$var = .011;
$var = -.011;

===
--- dscr: Basic failure
--- failures: 12
--- params:
--- input
$var = 01;
$var = 010;
$var = 001;
$var = 0010;
$var = -01;
$var = -010;
$var = -001;
$var = -0010;
$var = +01;
$var = +010;
$var = +001;
$var = +0010;

===
--- dscr: chmod
--- failures: 0
--- params:
--- input
$cnt = chmod 0755, 'foo', 'bar';
chmod 0755, @executables;

$cnt = chmod ( 0755, 'foo', 'bar' );
chmod ( 0755, @executables );

===
--- dscr: chmod with strict option
--- failures: 4
--- params: {prohibit_leading_zeros => {strict => 1}}
--- input
$cnt = chmod 0755, 'foo', 'bar';
chmod 0755, @executables;

$cnt = chmod ( 0755, 'foo', 'bar' );
chmod ( 0755, @executables );

===
--- dscr: dbmopen
--- failures: 0
--- params:
--- input
dbmopen %database, 'foo.db', 0600;
dbmopen ( %database, 'foo.db', 0600 );

===
--- dscr: dbmopen with strict option
--- failures: 2
--- params: {prohibit_leading_zeros => {strict => 1}}
--- input
dbmopen %database, 'foo.db', 0600;
dbmopen ( %database, 'foo.db', 0600 );

===
--- dscr: mkdir
--- failures: 0
--- params:
--- input
mkdir $directory, 0755;
mkdir ( $directory, 0755 );

===
--- dscr: mkdir with strict option
--- failures: 2
--- params: {prohibit_leading_zeros => {strict => 1}}
--- input
mkdir $directory, 0755;
mkdir ( $directory, 0755 );

===
--- dscr: sysopen
--- failures: 0
--- params:
--- input
sysopen $filehandle, $filename, O_RDWR, 0666;
sysopen ( $filehandle, $filename, O_WRONLY | O_CREAT | O_EXCL, 0666 );
sysopen ( $filehandle, $filename, (O_WRONLY | O_CREAT | O_EXCL), 0666 );

===
--- dscr: sysopen with strict option
--- failures: 3
--- params: {prohibit_leading_zeros => {strict => 1}}
--- input
sysopen $filehandle, $filename, O_RDWR, 0666;
sysopen ( $filehandle, $filename, O_WRONLY | O_CREAT | O_EXCL, 0666 );
sysopen ( $filehandle, $filename, (O_WRONLY | O_CREAT | O_EXCL), 0666 );

===
--- dscr: umask
--- failures: 0
--- params:
--- input
umask 002;
umask ( 002 );

===
--- dscr: umask with strict option
--- failures: 2
--- params: {prohibit_leading_zeros => {strict => 1}}
--- input
umask 002;
umask ( 002 );

