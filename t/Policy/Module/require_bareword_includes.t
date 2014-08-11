use strict;
use warnings;
use Perl::Lint::Policy::Modules::RequireBarewordIncludes;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::RequireBarewordIncludes';

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
--- dscr: basic pass, incomplete statements
--- failures: 0
--- params:
--- input
require; #incomplete statement
use;     #incomplete statement
no;      #incomplete statement
{require}; # for Devel::Cover
END_PERL

$policy = 'Modules::RequireBarewordIncludes';
is( pcritique($policy, \$code), 0, $policy);

===
--- dscr: basic failures
--- failures: 7
--- params:
--- input
require 'Exporter';
require 'My/Module.pl';
use 'SomeModule';
use q{OtherModule.pm};
use qq{OtherModule.pm};
no "Module";
no "Module.pm";

===
--- dscr: basic passes with module names
--- failures: 0
--- params:
--- input
use 5.008;
require MyModule;
use MyModule;
no MyModule;
use strict;

