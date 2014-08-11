use strict;
use warnings;
use Perl::Lint::Policy::Miscellanea::ProhibitFormats;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Miscellanea::ProhibitFormats';

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
--- dscr: standard failures
--- failures: 4
--- params:
--- input
format STDOUT =
@<<<<<<   @||||||   @>>>>>>
"left",   "middle", "right"
.

format =
@<<<<<<   @||||||   @>>>>>>
"foo",   "bar",     "baz"
.

format REPORT_TOP =
                                Passwd File
Name                Login    Office   Uid   Gid Home
------------------------------------------------------------------
.
format REPORT =
@<<<<<<<<<<<<<<<<<< @||||||| @<<<<<<@>>>> @>>>> @<<<<<<<<<<<<<<<<<
$name,              $login,  $office,$uid,$gid, $home
.

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
$hash{format} = 'foo';
%hash = ( format => 'baz' );
$object->format();

