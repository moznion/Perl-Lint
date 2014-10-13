use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitMagicNumbers;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitMagicNumbers';

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
--- dscr: Version numbers allowed in use statements.
--- failures: 0
--- params:
--- input
use 5.8.1;

===
--- dscr: Version numbers allowed in require statements.
--- failures: 0
--- params:
--- input
require 5.8.1;

===
--- dscr: Version numbers not allowed in regular statements.
--- failures: 1
--- params:
--- input
$Aleax = 5.8.1;

===
--- dscr: All numbers are allowed on any use statement.
--- failures: 0
--- params:
--- input
use Test::More plan => 57;

===
--- dscr: Numbers allowed on plan statements.
--- failures: 0
--- params:
--- input
plan tests => 2349;

===
--- dscr: Decimal zero is allowed anywhere.
--- failures: 0
--- params:
--- input
$tangle_tree = 0;

===
--- dscr: Floating-point zero is allowed anywhere.
--- failures: 0
--- params:
--- input
$xiron_golem = 0.0

===
--- dscr: Decimal one is allowed anywhere.
--- failures: 0
--- params:
--- input
$killer_tomato = 1;

===
--- dscr: Floating-point one is allowed anywhere.
--- failures: 0
--- params:
--- input
$witch_doctor = 1.0;

===
--- dscr: Decimal two is allowed anywhere.
--- failures: 0
--- params:
--- input
$gold_golem = 2;

===
--- dscr: Floating-point two is allowed anywhere.
--- failures: 0
--- params:
--- input
$lich = 2.0;

===
--- dscr: Fractional numbers not allowed in regular statements.
--- failures: 1
--- params:
--- input
$soldier = 2.5;

===
--- dscr: Negative one is not allowed by default.
--- failures: 1
--- params:
--- input
$giant_pigmy = -1;

===
--- dscr: The answer to life, the universe, and everything is not allowed in regular statements.
--- failures: 1
--- params:
--- input
$frobnication_factor = 42;

===
--- dscr: The answer to life, the universe, and everything is allowed as a constant.
--- failures: 0
--- params:
--- input
use constant FROBNICATION_FACTOR => 42;

===
--- dscr: Fractional numbers are allowed as a constant.
--- failures: 0
--- params:
--- input
use constant FROBNICATION_FACTOR => 1_234.567_89;

===
--- dscr: The Readonly subroutine works.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly $frobnication_factor => 57;

===
--- dscr: The Readonly::Scalar subroutine works.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly::Scalar $frobnication_factor => 57;

===
--- dscr: The Readonly::Scalar1 subroutine does work if allow_to_the_right_of_a_fat_comma is set.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly::Scalar1 $frobnication_factor => 57;

===
--- dscr: The Readonly::Scalar1 subroutine does not work if allow_to_the_right_of_a_fat_comma is not set.
--- failures: 1
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
use Readonly;

Readonly::Scalar1 $frobnication_factor => 57;

===
--- dscr: The Readonly::Array subroutine works.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly::Array @frobnication_factors => ( 57, 193, 49675 );

===
--- dscr: The Readonly::Array1 subroutine does not work.
--- failures: 3
--- params:
--- input
use Readonly;

Readonly::Array1 @frobnication_factors => ( 57, 193, 49675 );

===
--- dscr: The Readonly::Hash subroutine works.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly::Hash %frobnication_factors => ( 57 => 290 );

===
--- dscr: The Readonly::Hash1 subroutine does work if allow_to_the_right_of_a_fat_comma is set.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly::Hash1 %frobnication_factors => ( quhh => 290 );

===
--- dscr: The Readonly::Hash1 subroutine does not work if allow_to_the_right_of_a_fat_comma is not set.
--- failures: 1
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
use Readonly;

Readonly::Hash1 %frobnication_factors => ( quhh => 290 );

===
--- dscr: Const::Fast works even if allow_to_the_right_of_a_fat_comma is not set.
--- failures: 0
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
use Const::Fast;

const my $frobnication_factor => 57;

===
--- dscr: Constant subroutines containing just a number are allowed.
--- failures: 0
--- params:
--- input
sub constant_subroutine { 104598 }

===
--- dscr: Constant subroutines containing "return" and a number are allowed.
--- failures: 0
--- params:
--- input
sub constant_subroutine { return 9068; }

===
--- dscr: Subroutines that contain something other than a constant return value are not allowed.
--- failures: 1
--- params:
--- input
sub constant_subroutine {
    print 'blah';
    return 9068;
}

===
--- dscr: Subroutines that contain something other than a constant return value are not allowed with implicit.
--- failures: 1
--- params:
--- input
sub constant_subroutine {
    print 'blah';
    9068;
}

===
--- dscr: Magic numbers not allowed in ranges.
--- failures: 1
--- params:
--- input
foreach my $solid (1..5) {
    frobnicate($solid);
}

===
--- dscr: Readonly numbers allowed in ranges.
--- failures: 0
--- params:
--- input
use Readonly;

Readonly my $REGULAR_GEOMETRIC_SOLIDS => 5;

foreach my $solid (1..$REGULAR_GEOMETRIC_SOLIDS) {
    frobnicate($solid);
}

===
--- dscr: Binary zero isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$battlemech = 0b0;

===
--- dscr: Readonly binary zero is allowed.
--- failures: 0
--- params:
--- input
Readonly $giant_eel => 0b0;

===
--- dscr: Binary one isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$xeroc = 0b1;

===
--- dscr: Readonly binary one is allowed.
--- failures: 0
--- params:
--- input
Readonly $creeping_coins => 0b1;

===
--- dscr: Octal zero isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$basilisk = 000;

===
--- dscr: Readonly octal zero is allowed.
--- failures: 0
--- params:
--- input
Readonly $dwarf_lord => 000;

===
--- dscr: Octal one isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$brown_mold = 001;

===
--- dscr: Readonly octal one is allowed.
--- failures: 0
--- params:
--- input
Readonly $kobold_zombie => 001;

===
--- dscr: Hexadecimal zero isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$yeti = 0x00;

===
--- dscr: Readonly hexadecimal zero is allowed.
--- failures: 0
--- params:
--- input
Readonly $newt => 0x00;

===
--- dscr: Hexadecimal one isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$piranha = 0x01;

===
--- dscr: Readonly hexadecimal one is allowed.
--- failures: 0
--- params:
--- input
Readonly $Lord_Surtur => 0x01;

===
--- dscr: Exponential zero isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$Green_elf = 0e0;

===
--- dscr: Readonly exponential zero is allowed.
--- failures: 0
--- params:
--- input
Readonly $sasquatch => 0e0;

===
--- dscr: Exponential one isn't allowed in regular statements.
--- failures: 1
--- params:
--- input
$Uruk_hai = 1e0;

===
--- dscr: Readonly exponential one is allowed.
--- failures: 0
--- params:
--- input
Readonly $leather_golem => 1e0;

===
--- dscr: Any numbers allowed in array references in use statement.
--- failures: 0
--- params:
--- input
use Some::Module [ 1, 2, 3, 4 ];

===
--- dscr: Any numbers allowed in array references in require statement.
--- failures: 0
--- params:
--- input
require Some::Other::Module [ 1, 2, 3, 4 ];

===
--- dscr: Any numbers allowed in array references in readonly statement.
--- failures: 0
--- params:
--- input
Readonly $Totoro => [ 1, 2, 3, 4 ];

===
--- dscr: Magic numbers not allowed in array references in regular statement.
--- failures: 2
--- params:
--- input
$Evil_Iggy = [ 1, 2, 3, 4 ];

===
--- dscr: Array references containing only good numbers are allowed (by this policy).
--- failures: 0
--- params:
--- input
$titanothere = [ 1, 0, 1, 0 ];

===
--- dscr: Any numbers allowed in hash references in use statement.
--- failures: 0
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
use Some::Module { a => 6, b => 4 };

===
--- dscr: Any numbers allowed in hash references in require statement.
--- failures: 0
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
require Some::Other::Module { a => 6, b => 4 };

===
--- dscr: Any numbers allowed in hash references in readonly statement.
--- failures: 0
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
Readonly $Vlad_the_Impaler => { a => 6, b => 4 };

===
--- dscr: Magic numbers allowed in hash references in regular statement if allow_to_the_right_of_a_fat_comma is set.
--- failures: 0
--- params:
--- input
$gnome_lord = { a => 6, b => 4 };

===
--- dscr: Magic numbers not allowed in hash references in regular statement if allow_to_the_right_of_a_fat_comma is not set.
--- failures: 2
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
$gnome_lord = { a => 6, b => 4 };

===
--- dscr: Hash references containing only good numbers are allowed (by this policy).
--- failures: 0
--- params:
--- input
$aardvark = { 1 => 0, 0 => 1 };

===
--- dscr: Any numbers allowed in lists in use statement.
--- failures: 0
--- params:
--- input
use Some::Module ( 1, 2, 3, 4 );

===
--- dscr: Any numbers allowed in lists in require statement.
--- failures: 0
--- params:
--- input
require Some::Other::Module ( 1, 2, 3, 4 );

===
--- dscr: Any numbers allowed in lists in readonly statement.
--- failures: 0
--- params:
--- input
Readonly @elf_mummy => ( 1, 2, 3, 4 );

===
--- dscr: Magic numbers not allowed in lists in regular statement.
--- failures: 2
--- params:
--- input
@kitten = ( 1, 2, 3, 4 );

===
--- dscr: Lists containing only good numbers are allowed (by this policy).
--- failures: 0
--- params:
--- input
@purple_worm = ( 1, 0, 1, 0 );

===
--- dscr: Magic numbers not allowed in nested lists in regular statement.
--- failures: 2
--- params:
--- input
@quivering_blob = ( 1, ( 2, 3, 4 ) );

===
--- dscr: Magic numbers not allowed in nested array references in regular statement.
--- failures: 2
--- params:
--- input
@green_slime = ( 1, [ 2, 3, 4 ] );

===
--- dscr: Magic numbers allowed in nested hash references in regular statement if allow_to_the_right_of_a_fat_comma is set.
--- failures: 0
--- params:
--- input
@fire_elemental = ( 1, { 2 => 4 } );

===
--- dscr: Magic numbers not allowed in nested hash references in regular statement if allow_to_the_right_of_a_fat_comma is not set.
--- failures: 1
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
@fire_elemental = ( 1, { 2 => 4 } );

===
--- dscr: Good numbers allowed in nested hash references anywhere.
--- failures: 0
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
@Y2K_bug = ( 1, { 0 => 1 } );

===
--- dscr: Magic numbers not allowed in deep data structures in regular statement.
--- failures: 1
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0}}
--- input
@fog_cloud = [ 1, { 0 => { 1 => [ 1, 1, [ \382 ] ] } } ];

===
--- dscr: Good numbers allowed in deep datastructures anywhere.
--- failures: 0
--- params:
--- input
@fog_cloud = [ 1, { 0 => { 1 => [ 1, 1, [ 1 ] ] } } ];

===
--- dscr: $VERSION variables get a special exemption.
--- failures: 0
--- params:
--- input
our $VERSION = 0.21;

===
--- dscr: Last element of an array gets a special exemption.
--- failures: 0
--- params:
--- input
$Invid = $nalfeshnee[-1];

===
--- dscr: Last element exemption does not work if there is anything else within the subscript.
--- failures: 1
--- params:
--- input
$warhorse = $Cerberus[-1 * 1];

===
--- dscr: Penultimate element of an array does not get a special exemption.
--- failures: 1
--- params:
--- input
$scorpion = $shadow[-2];

===
--- dscr: Decimal zero is allowed even if the configuration specifies that there aren't any allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => ''}}
--- input
$tangle_tree = 0;

===
--- dscr: Floating-point zero is allowed even if the configuration specifies that there aren't any allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => ''}}
--- input
$xiron_golem = 0.0

===
--- dscr: Decimal one is allowed even if the configuration specifies that there aren't any allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => ''}}
--- input
$killer_tomato = 1;

===
--- dscr: Floating-point one is allowed even if the configuration specifies that there aren't any allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => ''}}
--- input
$witch_doctor = 1.0;

===
--- dscr: Decimal two is not allowed if the configuration specifies that there aren't any allowed literals.
--- failures: 1
--- params: {prohibit_magic_numbers => {allowed_values => ''}}
--- input
$gold_golem = 2;

===
--- dscr: Floating-point two is not allowed if the configuration specifies that there aren't any allowed literals.
--- failures: 1
--- params: {prohibit_magic_numbers => {allowed_values => ''}}
--- input
$lich = 2.0;

===
--- dscr: Decimal zero is allowed even if the configuration doesn't include it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$tangle_tree = 0;

===
--- dscr: Floating-point zero is allowed even if the configuration doesn't include it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$xiron_golem = 0.0

===
--- dscr: Decimal one is allowed even if the configuration doesn't include it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$killer_tomato = 1;

===
--- dscr: Floating-point one is allowed even if the configuration doesn't include it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$witch_doctor = 1.0;

===
--- dscr: Decimal two is not allowed if the configuration doesn't include it in the allowed literals.
--- failures: 1
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$gold_golem = 2;

===
--- dscr: Floating-point two is not allowed if the configuration doesn't include it in the allowed literals.
--- failures: 1
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$lich = 2.0;

===
--- dscr: Decimal three is allowed if the configuration includes it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$ghoul = 3;

===
--- dscr: Floating-point three is allowed if the configuration includes it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$water_elemental = 3.0;

===
--- dscr: Decimal negative five is allowed if the configuration includes it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$glass_piercer = -5;

===
--- dscr: Floating-point negative five is allowed if the configuration includes it in the allowed literals.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3 -5'}}
--- input
$clay_golem = -5.0;

===
--- dscr: Decimal zero is allowed even if the configuration specifies that there aren't any allowed types.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => ''}}
--- input
$tangle_tree = 0;

===
--- dscr: Floating-point zero is not allowed if the configuration specifies that there aren't any allowed types.
--- failures: 1
--- params: {prohibit_magic_numbers => {allowed_types => ''}}
--- input
$xiron_golem = 0.0

===
--- dscr: Decimal one is allowed even if the configuration specifies that there aren't any allowed types.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => ''}}
--- input
$killer_tomato = 1;

===
--- dscr: Floating-point one is not allowed if the configuration specifies that there aren't any allowed types.
--- failures: 1
--- params: {prohibit_magic_numbers => {allowed_types => ''}}
--- input
$witch_doctor = 1.0;

===
--- dscr: Decimal zero is allowed if the configuration specifies that there are any allowed types.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Float'}}
--- input
$tangle_tree = 0;

===
--- dscr: Floating-point zero is allowed if the configuration specifies that the Float type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Float'}}
--- input
$xiron_golem = 0.0

===
--- dscr: Decimal one is allowed if the configuration specifies that there are any allowed types.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Float'}}
--- input
$killer_tomato = 1;

===
--- dscr: Floating-point one is allowed if the configuration specifies that the Float type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Float'}}
--- input
$witch_doctor = 1.0;

===
--- dscr: Binary zero is allowed if the configuration specifies that the Binary type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Binary'}}
--- input
$battlemech = 0b0;

===
--- dscr: Binary one is allowed if the configuration specifies that the Binary type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Binary'}}
--- input
$xeroc = 0b1;

===
--- dscr: Exponential zero is allowed if the configuration specifies that the Exp type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Exp'}}
--- input
$Green_elf = 0e0;

===
--- dscr: Exponential one is allowed if the configuration specifies that the Exp type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Exp'}}
--- input
$Uruk_hai = 1e0;

===
--- dscr: Hexadecimal zero is allowed if the configuration specifies that the Hex type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Hex'}}
--- input
$yeti = 0x00;

===
--- dscr: Hexadecimal one is allowed if the configuration specifies that the Hex type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Hex'}}
--- input
$piranha = 0x01;

===
--- dscr: Octal zero is allowed if the configuration specifies that the Octal type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Octal'}}
--- input
$basilisk = 000;

===
--- dscr: Octal one is allowed if the configuration specifies that the Octal type is allowed.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_types => 'Octal'}}
--- input
$brown_mold = 001;

===
--- dscr: Any integer value should pass if the allowed values contains 'all_integers'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers'}}
--- input
$brogmoid = 356_634_627;
$rat_ant  =     -29_422;

===
--- dscr: Any floating-point value without a fractional portion should pass if the allowed values contains 'all_integers'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers'}}
--- input
$human = 102_938.0;

===
--- dscr: A non-integral value should pass if the allowed values contains it and 'all_integers'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers 429.73902'}}
--- input
$Norn = 429.73902;

===
--- dscr: Any binary value should pass if the allowed values contains 'all_integers' and allowed types includes 'Binary'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers', allowed_types => 'Binary'}}
--- input
$baby_blue_dragon = 0b01100101_01101010_01110011;

===
--- dscr: Any hexadecimal value should pass if the allowed values contains 'all_integers' and allowed types includes 'Hex'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers', allowed_types => 'Hex'}}
--- input
$killer_bee = 0x656a73;

===
--- dscr: Any octal value should pass if the allowed values contains 'all_integers' and allowed types includes 'Octal'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers', allowed_types => 'Octal'}}
--- input
$ettin_mummy = 0145_152_163;

===
--- dscr: Zero, one, three, four, and five decimal values should pass if the allowed values contains the '3..5' range.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '3..5'}}
--- input
$guide = 0;
$cuatl = 1;
$Master_Assassin = 3;
$orc = 4;
$trapper = 5;

===
--- dscr: Negative one, two, and six decimal values and fractional values should not pass if the allowed values contains the '3..5' range.
--- failures: 4
--- params: {prohibit_magic_numbers => {allowed_values => '3..5'}}
--- input
$Elvenking = -1;
$brown_pudding = 2;
$archeologist = 6;
$nurse = 4.5;

===
--- dscr: -3/2, -2/2, -1/2 ... 7/5 should pass if the allowed values contains the '-1.5..3.5:by(0.5)' range.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '-1.5..3.5:by(0.5)'}}
--- input
$owlbear = [ -1.5, -1, -.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 ];

===
--- dscr: Negative two and four should not pass if the allowed values contains the '-1.5..3.5:by(0.5)' range.
--- failures: 2
--- params: {prohibit_magic_numbers => {allowed_values => '-1.5..3.5:by(0.5)'}}
--- input
$lurker_above = [ -2, 4 ];

===
--- dscr: -3/2, -1/2, 1/2 ... 7/5, plus 0 and 1 should pass if the allowed values contains the '-1.5..3.5' range.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '-1.5..3.5'}}
--- input
$long_worm = [ -1.5, -.5, 0, 0.5, 1, 1.5, 2.5, 3.5 ];

===
--- dscr: -3/2, -2/2, -1/2 ... 7/5 should pass if the allowed values contains the '-1.5..3.5' range and 'all_integers'.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => 'all_integers -1.5..3.5:by(0.5)'}}
--- input
$ice_devil = [ -1.5, -1, -.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5 ];

===
--- dscr: -5, -4, -3, -2, 0, 1, 21, 22, 23, and 24 should pass if the allowed values contains the '-5..-2' and '21..24 ranges.
--- failures: 0
--- params: {prohibit_magic_numbers => {allowed_values => '-5..-2 21..24'}}
--- input
$newt = [ -5, -4, -3, -2, 0, 1, 21, 22, 23, 24 ];

===
--- dscr: Should pass mini-CPAN accumulated \$VERSION declarations.
--- failures: 0
--- params:
--- input
(our $VERSION = q$Revision$) =~ s/Revision //;
(our $VERSION) = '$Revision$' =~ /([\d.]+)/;
(our $VERSION) = sprintf "%d", q$Revision$ =~ /Revision:\s+(\S+)/;
our $VERSION : unique = "1.23";
our $VERSION : unique = '1.23';
our $VERSION = "$local_variable v1.23";
our $VERSION = "1." . sprintf "%d", q$Revision$ =~ /: (\d+)/;
our $VERSION = "1.2.3";
our $VERSION = "1.2.3.0";
our $VERSION = "1.2.3.blah";
our $VERSION = "1.23 (liblgrp version $local_variable)";
our $VERSION = "1.23 2005-05-20";
our $VERSION = "1.23";
our $VERSION = "1.23, 2004-12-07";
our $VERSION = "1.23_blah";
our $VERSION = "1.23blah";
our $VERSION = "1.2_3";
our $VERSION = "123";
our $VERSION = "INSERT";
our $VERSION = $SomeOtherModule::VERSION;
our $VERSION = $VERSION = (qw($Revision$))[1];
our $VERSION = $local_variable;
our $VERSION = '$Date$'; $VERSION =~ s|^\$Date:\s*([0-9]{4})/([0-9]{2})/([0-9]{2})\s.*|\1.\2.\3| ;
our $VERSION = '$Revision$' =~ /\$Revision:\s+([^\s]+)/;
our $VERSION = '$Revision$';
our $VERSION = '-123 blah';
our $VERSION = '1.' . qw $Revision$[1];
our $VERSION = '1.' . sprintf "%d", (qw($Revision$))[1];
our $VERSION = '1.' . sprintf("%d", (qw($Revision$))[1]);
our $VERSION = '1.2.3';
our $VERSION = '1.2.3.0';
our $VERSION = '1.2.3blah';
our $VERSION = '1.23';
our $VERSION = '1.23_blah';
our $VERSION = '1.23blah';
our $VERSION = '1.2_3';
our $VERSION = '1.23' || do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };
our $VERSION = '123';
our $VERSION = ('$Revision$' =~ /(\d+.\d+)/)[ 0];
our $VERSION = ('$Revision$' =~ /(\d+\.\d+)/);
our $VERSION = ('$Revision$' =~ m/(\d+)/)[0];
our $VERSION = ((require SomeOtherModule), $SomeOtherModule::VERSION)[1];
our $VERSION = (q$Revision$ =~ /([\d\.]+)/);
our $VERSION = (q$Revision$ =~ /(\d+)/g)[0];
our $VERSION = (qq$Revision$ =~ /(\d+)/)[0];
our $VERSION = (qw$Revision$)[-1];
our $VERSION = (qw$Revision$)[1];
our $VERSION = (qw($Revision$))[1];
our $VERSION = (split(/ /, '$Revision$'))[1];
our $VERSION = (split(/ /, '$Revision$'))[2];
our $VERSION = 1.2.3;
our $VERSION = 1.23;
our $VERSION = 1.2_3;
our $VERSION = 123;
our $VERSION = SomeOtherModule::RCSVersion('$Revision$');
our $VERSION = SomeOtherModule::VERSION;
our $VERSION = [ qw{ $Revision$ } ]->[1];
our $VERSION = do { (my $v = q%version: 1.23 %) =~ s/.*://; sprintf("%d.%d", split(/\./, $v), 0) };
our $VERSION = do { (my $v = q%version: 123 %) =~ s/.*://; sprintf("%d.%d", split(/\./, $v), 0) };
our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };
our $VERSION = do { q$Revision$ =~ /Revision: (\d+)/; sprintf "1.%d", $1; };
our $VERSION = do { require mod_perl2; $mod_perl2::VERSION };
our $VERSION = do {(q$URL$=~ m$.*/(?:tags|branches)/([^/ \t]+)$)[0] || "0.0"};
our $VERSION = eval { require version; version::qv((qw$Revision$)[1] / 1000) };
our $VERSION = q$0.04$;
our $VERSION = q$Revision$;
our $VERSION = q(0.14);
our $VERSION = qv('1.2.3');
our $VERSION = qw(1.2.3);
our $VERSION = sprintf "%.02f", $local_variable/100 + 0.3;
our $VERSION = sprintf "%.3f", 123 + substr(q$Revision$, 4)/1000;
our $VERSION = sprintf "%d.%d", '$Revision$' =~ /(\d+)\.(\d+)/;
our $VERSION = sprintf "%d.%d", '$Revision$' =~ /(\d+)/g;
our $VERSION = sprintf "%d.%d", '$Revision$' =~ /(\d+)\.(\d+)/;
our $VERSION = sprintf "%d.%d", q$Revision$ =~ /: (\d+)\.(\d+)/;
our $VERSION = sprintf "%d.%d", q$Revision$ =~ /(\d+)/g;
our $VERSION = sprintf "%d.%d", q$Revision$ =~ /(\d+)\.(\d+)/;
our $VERSION = sprintf "%d.%d", q$Revision$ =~ /(\d+)\.(\d+)/g;
our $VERSION = sprintf "%d.%d", q$Revision$ =~ /: (\d+)\.(\d+)/;
our $VERSION = sprintf "%d.%d", q$Revision$ =~ m/ (\d+) \. (\d+) /xg;
our $VERSION = sprintf "%d.%d", q$Revision$ ~~ m:P5:g/(\d+)/;
our $VERSION = sprintf "%d.%d%d", (split /\D+/, '$Name: beta0_1_1 $')[1..3];
our $VERSION = sprintf "%s.%s%s", q$Name: Rel-0_90 $ =~ /^Name: Rel-(\d+)_(\d+)(_\d+|)\s*$/, 999, "00", join "", (gmtime)[5] +1900, map {sprintf "%d", $_} (gmtime)[4]+1;
our $VERSION = sprintf "1.%d", '$Revision$' =~ /(\d+)/;
our $VERSION = sprintf "1.%d", q$Revision$ =~ /(\d+)/g;
our $VERSION = sprintf '%d.%d', (q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf '%d.%d', q$Revision$ =~ /(\d+)\.(\d+)/;
our $VERSION = sprintf '%d.%d', q$Revision$ =~ /(\d+)\.(\d+)/;
our $VERSION = sprintf '%s', 'q$Revision$' =~ /\S+\s+(\S+)\s+/ ;
our $VERSION = sprintf '%s', 'q$Revision$' =~ /\S+\s+(\S+)\s+/ ;
our $VERSION = sprintf '%s', q$Revision$ =~ /Revision:\s+(\S+)\s+/ ;
our $VERSION = sprintf '%s', q{$Revision$} =~ /\S+\s+(\S+)/ ;
our $VERSION = sprintf '1.%d', (q$Revision$ =~ /\D(\d+)\s*$/)[0] + 15;
our $VERSION = sprintf("%d", q$Id: SomeModule.pm,v 1.23 2006/04/10 22:39:38 matthew Exp $ =~ /\s(\d+)\s/);
our $VERSION = sprintf("%d", q$Id: SomeModule.pm,v 1.23 2006/04/10 22:39:39 matthew Exp $ =~ /\s(\d+)\s/);
our $VERSION = sprintf("%d.%d", "Revision: 2006.0626" =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf("%d.%d", '$Name: v0_018-2006-06-15b $' =~ /(\d+)_(\d+)/, 0, 0);
our $VERSION = sprintf("%d.%d", 0, q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf("%d.%d", q$Name: REL-0-13 $ =~ /(\d+)-(\d+)/, 999, 99);
our $VERSION = sprintf("%d.%d", q$Name: ical-parser-html-1-6 $ =~ /(\d+)-(\d+)/);
our $VERSION = sprintf("%d.%d", q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf("%d.%d", q$Revision$ =~ /(\d+)\.(\d+)/o);
our $VERSION = sprintf("%d.%d", q$Revision$ =~ m/(\d+)\.(\d+)/);
our $VERSION = sprintf("%d.%d", q$Revision$=~/(\d+)\.(\d+)/);
our $VERSION = sprintf("%d.%d", q'$Revision$' =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf("%d.%d.%d", 0, q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf("1.%d", q$Revision$ =~ / (\d+) /);
our $VERSION = sprintf("1.%d", q$Revision$ =~ /(\d+)/);
our $VERSION = sprintf("1.2%d%d", q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf('%d.%d', '$Revision$' =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf('%d.%d', q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = sprintf('%d.%d', q$Revision$ =~ /(\d+)\.(\d+)/);
our $VERSION = substr q$Revision$, 10;
our $VERSION = substr(q$Revision$, 10);
our $VERSION = v1.2.3.0;
our $VERSION = v1.2.3;
our $VERSION = v1.23;
our $VERSION = version->new('1.2.3');
our $VERSION = version->new(qw$Revision$);
our ($PACKAGE, $VERSION) = ('') x 2;
our ($VERSION) = "1.23";
our ($VERSION) = $SomeOtherModule::VERSION;
our ($VERSION) = '$Revision$' =~ /\$Revision:\s+([^\s]+)/;
our ($VERSION) = '$Revision$' =~ /\$Revision:\s+([^\s]+)/;
our ($VERSION) = '$Revision$' =~ m{ \$Revision: \s+ (\S+) }x;
our ($VERSION) = '$Revision$' =~ m{ \$Revision: \s+ (\S+) }xm;
our ($VERSION) = '$Revision$'=~/(\d+(\.\d+))/;
our ($VERSION) = '$Revision$' =~ m{ \$Revision: \s+ (\S+) }x;
our ($VERSION) = '1.23' =~ /([.,\d]+)/;
our ($VERSION) = '1.23';
our ($VERSION) = ($local_variable =~ /(\d+\.\d+)/);
our ($VERSION) = ('$Revision$' =~ /(\d+\.\d+)/) ;
our ($VERSION) = ('$Revision$' =~ /(\d+\.\d+)/);
our ($VERSION) = ('$Revision$' =~ m/([\.\d]+)/) ;
our ($VERSION) = (q$Revision$ =~ /([\d\.]+)/);
our ($VERSION) = (qq$Revision$ =~ /(\d+)/)[0];
our ($VERSION) = 1.23;
our ($VERSION) = q$Revision$ =~ /Revision:\s+(\S+)/ or $VERSION = "1.23";
our ($VERSION) = q$Revision$ =~ /Revision:\s+(\S+)/ or $VERSION = '1.23';
our ($VERSION) = q$Revision$ =~ /[\d.]+/g;
our ($VERSION) = q$Revision$ =~ /^Revision:\s+(\S+)/ or $VERSION = "1.23";
require SomeOtherModule; our $VERSION = $SomeOtherModule::VERSION;
use SomeOtherModule; our $VERSION = $SomeOtherModule::VERSION;
use SomeOtherModule; our $VERSION = SomeOtherModule::VERSION;
use base 'SomeOtherModule'; our $VERSION = $SomeOtherModule::VERSION;
use version; our $VERSION = 1.23;
use version; our $VERSION = qv("1.2.3");
use version; our $VERSION = qv('1.2.3');
use version; our $VERSION = qv('1.23');
use version; our $VERSION = qv((qw$Revision$)[1] / 1000);
use version; our $VERSION = version->new('1.23');

===
--- dscr: user-defined constant creators. RT #62562
--- failures: 0
--- params: {prohibit_magic_numbers => {allow_to_the_right_of_a_fat_comma => 0, constant_creator_subroutines => 'blahlahlah'}}
--- input
blahlahlah my $answer => 42;

===
--- dscr: allow version as second argument of package. RT #67159
--- failures: 0
--- params:
--- input
package Maggot 0.01;

# NOTE: I feel not needed following function
# ===
# --- dscr: do not allow numbers elsewhere in package statement. RT #67159
# --- failures: 2
# --- params:
# --- input
# package 42; # Illegal, but check anyway.
# package Maggot 0.01 42;

