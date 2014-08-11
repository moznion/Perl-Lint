use strict;
use warnings;
use Perl::Lint::Policy::Modules::ProhibitEvilModules;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::ProhibitEvilModules';

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
--- dscr: Deprecated Class::ISA
--- failures: 1
--- params:
--- input
use Class::ISA;

===
--- dscr: Deprecated Pod::Plainer
--- failures: 1
--- params:
--- input
use Pod::Plainer;

===
--- dscr: Deprecated Shell
--- failures: 1
--- params:
--- input
use Shell;

===
--- dscr: Deprecated Switch
--- failures: 1
--- params:
--- input
use Switch;

===
--- dscr: 2 evil modules
--- failures: 2
--- params: {prohibit_evil_modules => {modules => 'Evil::Module Super::Evil::Module'}}
--- input
use Evil::Module qw(bad stuff);
use Super::Evil::Module;

===
--- dscr: No evil modules
--- failures: 0
--- params: {prohibit_evil_modules => {modules => ' Evil::Module Super::Evil::Module'}}
--- input
use Good::Module;

===
--- dscr: 2 evil modules, with pattern matching
--- failures: 2
--- params: {prohibit_evil_modules => {modules => '/Evil::/ /Demonic/ '}}
--- input
use Evil::Module qw(bad stuff);
use Demonic::Module

===
--- dscr: More evil modules, with mixed config
--- failures: 4
--- params: {prohibit_evil_modules => {modules => ' /Evil::/ Demonic::Module /Acme/'}}
--- input
use Evil::Module qw(bad stuff);
use Super::Evil::Module;
use Demonic::Module;
use Acme::Foo;

===
--- dscr: More evil modules, with more pattern matching
--- failures: 4
--- params: {prohibit_evil_modules => {modules => '/Evil::|Demonic::Module|Acme/ '}}
--- input
use Evil::Module qw(bad stuff);
use Super::Evil::Module;
use Demonic::Module;
use Acme::Foo;

===
--- dscr: Pattern matching exceptions
--- failures: 0
--- params: {prohibit_evil_modules => {modules => '/(/'}}
--- input
print 'Hello World';

===
--- dscr: Providing the description for modules, no regular expressions.
--- failures: 2
--- params: {prohibit_evil_modules => {modules => q' Fatal{Found use of Fatal. Use autodie instead} Getopt::Std {Found use of Getopt::Std. Use Getopt::Long instead} '}}
--- input
use Fatal qw< open close >;
use Getopt::Std;

===
--- dscr: Providing the description for modules, regular expressions.
--- failures: 2
--- params: {prohibit_evil_modules => {modules => q' /Fatal/{Found use of Fatal. Use autodie instead} /Getopt::Std/ {Found use of Getopt::Std. Use Getopt::Long instead} '}}
--- input
use Fatal qw< open close >;
use Getopt::Std;

===
--- dscr: Providing the description for modules, no regular expressions.
--- failures: 3
--- params: {prohibit_evil_modules => {modules_file => 't/Policy/Module/prohibit_evil_modules/modules-no-regular-expressions.txt'}}
--- input
use Evil;
use Fatal qw< open close >;
use Getopt::Std;

===
--- dscr: Providing the description for modules, regular expressions.
--- failures: 3
--- params: {prohibit_evil_modules => {modules_file => 't/Policy/Module/prohibit_evil_modules/modules-regular-expressions.txt'}}
--- input
use Evil;
use Fatal qw< open close >;
use Getopt::Std;

