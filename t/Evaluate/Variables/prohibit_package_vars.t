use strict;
use warnings;
use Perl::Lint::Evaluator::Variables::ProhibitPackageVars;
use t::Evaluate::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Variables::ProhibitPackageVars';

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
--- dscr: Basic failures
--- failures: 15
--- params:
--- input
our $var1 = 'foo';
our (%var2, %var3) = 'foo';
our (%VAR4, $var5) = ();

$Package::foo;
@Package::list = ('nuts');
%Package::hash = ('nuts');

$::foo = $bar;
@::foo = ($bar);
%::foo = ();

use vars qw($fooBar $baz);
use vars qw($fooBar @EXPORT);
use vars '$fooBar', "$baz";
use vars '$fooBar', '@EXPORT';
use vars ('$fooBar', '$baz');
use vars ('$fooBar', '@EXPORT');

===
--- dscr: Basic passes - our
--- failures: 0
--- params:
--- input
our $VAR1 = 'foo';
our (%VAR2, %VAR3) = ();
our $VERSION = '1.0';
our @EXPORT = qw(some symbols);

===
--- dscr: Basic passes - use vars
--- failures: 0
--- params:
--- input
use vars qw($VERSION @EXPORT);
use vars ('$VERSION', '@EXPORT');
use vars  '$VERSION', '@EXPORT';

use vars  '+foo'; #Illegal, but not a violaton

===
--- dscr: Basic passes - symbols
--- failures: 0
--- params:
--- input
local $Foo::bar;
local @This::that;
local %This::that;
local $This::that{ 'key' };
local $This::that[ 1 ];
local (@Baz::bar, %Baz::foo);

$Package::VERSION = '1.2';
%Package::VAR = ('nuts');
@Package::EXPORT = ();

$::VERSION = '1.2';
%::VAR = ('nuts');
@::EXPORT = ();
&Package::my_sub();
&::my_sub();
*foo::glob = $code_ref;

===
--- dscr: Lexicals should pass
--- failures: 0
--- params:
--- input
my $var1 = 'foo';
my %var2 = 'foo';
my ($foo, $bar) = ();

# #-----------------------------------------------------------------------------
#
# ## name Default package exceptions
# ## failures 0
# ## cut
#
# use File::Find;
# print $File::Find::dir;
# use Data::Dumper;
# $Data::Dumper::Indent = 1;
#
#
# use File::Spec::Functions qw< catdir >;
# use lib catdir( $FindBin::Bin, qw< .. lib perl5 > );
#
# local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
#
# #-----------------------------------------------------------------------------
#
# ## name Add to default exceptions
# ## parms {add_packages => 'Addl::Package'}
# ## failures 3
# ## cut
#
#
# use File::Find;
# print $File::Find::dir;
#
# $Addl::Package::bar = 27;
#
# $Addl::Other::wango = 9;
# $Addl::Other::tango = 9;
# $Addl::Other::bango = 9;
#
#
# #-----------------------------------------------------------------------------
#
# ## name Override default package exceptions
# ## parms {add_packages => 'Incorrect::Override::Package'}
# ## failures 2
# ## cut
#
# use File::Find;
# print $File::Find::dir;
# $Override::Defaults::wango = $x;
# $Override::Defaults::tango = 47;
#
# #-----------------------------------------------------------------------------
#
# ## name Override default package exceptions, null package
# ## parms {add_packages => 'Incorrect::Override::Package'}
# ## failures 1
# ## cut
#
# $::foo = 1;
#
