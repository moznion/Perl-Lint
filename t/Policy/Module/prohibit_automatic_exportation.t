use strict;
use warnings;
use Perl::Lint::Policy::Modules::ProhibitAutomaticExportation;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::ProhibitAutomaticExportation';

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
--- dscr: Basic failure, "our @EXPORT;"
--- failures: 1
--- params:
--- input
require Exporter;
our @EXPORT = qw(foo bar);

===
--- dscr: Basic failure, "use vars @EXPORT;"
--- failures: 1
--- params:
--- input
use Exporter;
use vars '@EXPORT';
@EXPORT = qw(foo bar);

===
--- dscr: Basic failure, "@PACKAGE::EXPORT;"
--- failures: 1
--- params:
--- input
use base 'Exporter';
@Foo::EXPORT = qw(foo bar);

===
--- dscr: Basic pass, "our @EXPORT_OK;"
--- failures: 0
--- params:
--- input
require Exporter;
our @EXPORT_OK = ( '$foo', '$bar' );

===
--- dscr: Basic pass, "use vars %EXPORT_TAGS;"
--- failures: 0
--- params:
--- input
use Exporter;
use vars '%EXPORT_TAGS';
%EXPORT_TAGS = ();

===
--- dscr: Basic pass, "@PACKAGE::EXPORT_OK;"
--- failures: 0
--- params:
--- input
use base 'Exporter';
@Foo::EXPORT_OK = qw(foo bar);

===
--- dscr: Basic pass, "use vars '@EXPORT_OK';"
--- failures: 0
--- params:
--- input
use base 'Exporter';
use vars qw(@EXPORT_OK);
@EXPORT_OK = qw(foo bar);

===
--- dscr: Basic pass, "use vars '%EXPORT_TAGS';"
--- failures: 0
--- params:
--- input
use base 'Exporter';
use vars qw(%EXPORT_TAGS);
%EXPORT_TAGS = ( foo => [ qw(baz bar) ] );

===
--- dscr: No exporting at all
--- failures: 0
--- params:
--- input
print 123; # no exporting at all; for test coverage

===
--- dscr: No special variable to export
--- failures: 0
--- params:
--- input
our @Foo::EXPORT::Bar = qw(foo bar);

