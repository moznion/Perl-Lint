use strict;
use warnings;
use Perl::Lint::Policy::Modules::RequireExplicitPackage;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::RequireExplicitPackage';

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
--- dscr: one statement before package
--- failures: 1
--- params:
--- input
$foo = $bar;
package foo;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy.' 1 stmnt before package');

===
--- dscr: BEGIN block before package
--- failures: 1
--- params:
--- input
BEGIN{
    print 'Hello';        #this violation will be squelched
    print 'Beginning';    #this violation will be squelched
}

package foo;

===
--- dscr: inclusion before package
--- failures: 1
--- params:
--- input
use Some::Module;
package foo;

===
--- dscr: two statements before package
--- failures: 1
--- params:
--- input
$baz = $nuts;
print 'whatever';      #this violation will be squelched
package foo;

===
--- dscr: no package at all
--- failures: 1
--- params:
--- input
print 'whatever';

===
--- dscr: no statements at all
--- failures: 0
--- params:
--- input
# no statements

===
--- dscr: just a package, no statements
--- failures: 0
--- params:
--- input
package foo;

===
--- dscr: package OK
--- failures: 0
--- params:
--- input
package foo;
use strict;
$foo = $bar;

===
--- dscr: programs can be exempt
--- failures: 0
--- params: {require_explicit_package => {exempt_scripts => 1}}
--- input
#!/usr/bin/perl
$foo = $bar;
package foo;

===
--- dscr: programs not exempted
--- failures: 1
--- params: {require_explicit_package => {exempt_scripts => 0}}
--- input
#!/usr/bin/perl
use strict;
use warnings;          #this violation will be squelched
my $foo = 42;          #this violation will be squelched

===
--- dscr: programs not exempted, but we have a package
--- failures: 0
--- params: {require_explicit_package => {exempt_scripts => 0}}
--- input
#!/usr/bin/perl
package foo;
$foo = $bar;

===
--- dscr: Allow exception for specific module loads. RT #72660
--- failures: 0
--- params: {require_explicit_package => {allow_import_of => ['utf8', 'Foo::Bar']}}
--- input
use utf8;
use Foo::Bar;

package Foo::Bar;

