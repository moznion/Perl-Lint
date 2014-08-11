use strict;
use warnings;
use Perl::Lint::Policy::Modules::RequireFilenameMatchesPackage;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::RequireFilenameMatchesPackage';

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, {}, $block->filename);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: Basic passes.
--- failures: 0
--- filename: OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: Filename/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: lib/Filename/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: blib/lib/Filename/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: OK.pl
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: Filename-OK-1.00/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: Filename-OK/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic passes.
--- failures: 0
--- filename: Foobar-1.00/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic Failure.
--- failures: 1
--- filename: Bad.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic Failure.
--- failures: 1
--- filename: Filename/Bad.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic Failure.
--- failures: 1
--- filename: lib/Filename/BadOK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic Failure.
--- failures: 1
--- filename: ok.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic Failure.
--- failures: 1
--- filename: filename/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: Basic Failure.
--- failures: 1
--- filename: Foobar/OK.pm
--- input
package Filename::OK;
1;

===
--- dscr: first package is main, with inner package
--- filename: some_script
--- failures: 0
--- input
package main;

Inner::frobulate( @ARGV );

package Inner;

sub frobulate{};

1;

===
--- dscr: second package is main, with inner package
--- filename: some_script
--- failures: 1
--- input

package Inner;

sub frobulate{};

package main;

Inner::frobulate( @ARGV );

1;

# TODO
# ===
# --- dscr: Pass with apostrophe.
# --- filename: Oh.pm
# --- failures: 0
# --- input
# package D'Oh;
# 1;

# TODO
# ===
# --- dscr: Pass with apostrophe.
# --- filename: D/Oh.pm
# --- failures: 0
# --- input
# package D'Oh;
# 1;

# TODO
# ===
# --- dscr: Failure with apostrophe.
# --- filename: oh.pm
# --- failures: 1
# --- input
# package D'Oh;
# 1;

# TODO
# ===
# --- dscr: Failure with apostrophe.
# --- filename: d/Oh.pm
# --- failures: 1
# --- input
# package D'Oh;
# 1;

===
--- dscr: programs are exempt
--- failures: 0
--- filename: foo.plx
--- input
#!/usr/bin/perl
package Wibble;

===
--- dscr: using #line directive with double-quoted filename
--- filename: Foo.pm
--- failures: 0
--- input
#line 99 "Bar.pm"
package Bar;

===
--- dscr: using #line directive with bareword filename
--- filename: Foo.pm
--- failures: 0
--- input
#line 99 Bar.pm
package Bar;

===
--- dscr: #line directive appears after package declaration
--- filename: Foo.pm
--- failures: 1
--- input
package Bar;
#line 99 Bar.pm

===
--- dscr: multiple #line directives
--- filename: Foo.pm
--- failures: 1
--- input
#line 99 Bar.pm
#line 999 Baz.pm
package Bar;

===
--- dscr: #line directive with multi-part path
--- filename: Wrong.pm
--- failures: 0
--- input
#line 99 Foo/Bar/Baz.pm
package Foo::Bar::Baz;

===
--- dscr: #line directive with multi-part path in lib/ dir
--- filename: lib/Wrong.pm
--- failures: 0
--- input
#line 99 lib/Foo/Bar/Baz.pm
package Foo::Bar::Baz;

===
--- dscr: #line directive with partially matching multi-part path
--- filename: Wrong.pm
--- failures: 0
--- input
#line 99 Foo/Bar/Baz.pm
package Baz;

===
--- dscr: no package declaration at all
--- filename: Foo.pm
--- failures: 0
--- input

1;

===
--- dscr: #line directive with no package declaration at all
--- filename: Foo.pm
--- failures: 0
--- input
#line 1 Baz.pm
1;

