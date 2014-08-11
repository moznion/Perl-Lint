use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitVersionStrings;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitVersionStrings';

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
use 5.006_001;
require 5.006_001;

use Foo 1.0203;
require Foo 1.0203;

use Foo 1.0203 qw(foo bar);
require Foo 1.0203 qw(foo bar);

is( pcritique($policy, \$code), 0, $policy);

use lib '/usr/lib/perl5/vendor_perl/5.8.8'; # RT #30388

===
--- dscr: use failure
--- failures: 9
--- params:
--- input
use 5.6.1;
use v5.6.1;
use Foo 1.2.3;
use Foo v1.2.3;
use Foo 1.2.3 qw(foo bar);
use Foo v1.2.3 qw(foo bar);
use Foo v1.2.3 ('foo', 'bar');
use Foo::Bar 1.2.3;
use Foo::Bar v1.2.3;

===
--- dscr: require failure
--- failures: 9
--- params:
--- input
require 5.6.1;
require v5.6.1;
require Foo 1.2.3;
require Foo v1.2.3;
require Foo 1.2.3 qw(foo bar);
require Foo v1.2.3 qw(foo bar);
require Foo v1.2.3 ('foo', 'bar');
require Foo::Bar 1.2.3;
require Foo::Bar v1.2.3;

===
--- dscr: embedded comment - RT 44986
--- failures: 0
--- params:
--- input
use Foo::Bar xyzzy => 1;
use Foo::Bar
# With Foo::Bar 1.2.3 we can use the 'plugh' option.
plugh => 1;

