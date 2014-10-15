use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::RequireBriefOpen;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::RequireBriefOpen';

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
--- dscr: open .. close
--- failures: 0
--- params:
--- input
open my $fh1, '<', $filename or die;
close $fh1;
open my $fh2, '<', $filename or die;
close $fh2;
if (open my $fh3, '<', $filename) {
    close $fh3;
}

my $fh4;
open $fh4, '<', $filename or die;
close $fh4;

===
--- dscr: OO
--- failures: 0
--- params:
--- input
open my $fh1, '<', $filename or die;
$fh1->close;

===
--- dscr: else
--- failures: 0
--- params:
--- input
if (!open my $fh3, '<', $filename) {
    croak;
} else {
    close $fh3;
}

===
--- dscr: while .. print
--- failures: 0
--- params:
--- input
open my $fh1, '<', $filename or die;
while (<$fh1>) {
    print;
}
close $fh1;

if (open my $fh2, '<', $filename) {
    while (<$fh2>) {
        print;
    }
    close $fh2;
}

===
--- dscr: basic failures
--- failures: 2
--- params:
--- input
open my $fh1, '<', $filename or die;
close $fh0;
if (open my $fh2, '<', $filename) {
    while (<$fh2>) {
        print;
    }
}

===
--- dscr: lexical wrong name failure
--- failures: 2
--- params:
--- input
open my $fh1, '<', $filename or die;
close $fh2;
open my $fh3, '<', $filename or die;
$fh4->close;

===
--- dscr: scope failure
--- failures: 1
--- params:
--- input
{
    open my $fh1, '<', $filename;
}
close $fh1;

===
--- dscr: glob scope failure; no longer fails w/ RT #64437 applied.
--- failures: 0
--- params:
--- input
{
    open FH1, '<', $filename;
}
close FH1;

===
--- dscr: glob filehandle
--- failures: 0
--- params:
--- input
local (*FH1);
open FH1, '<', $filename or die;
close FH1;

===
--- dscr: glob failure
--- failures: 2
--- params:
--- input
local (*FH2);
open FH2, '<', $filename or die;
open *FH3, '<', $filename or die;

===
--- dscr: glob wrong name failure
--- failures: 1
--- params:
--- input
local (*FH1);
open FH1, '<', $filename or die;
close FH2;

===
--- dscr: we do not flag non-uppercase globs -- maybe it is a sub call
--- failures: 0
--- params:
--- input
local (*fh1);
open fh1, '<', $filename or die;

===
--- dscr: fail blocks
--- failures: 2
--- params:
--- input
my $foo;
open {$foo}, '<', $filename or die;

open {*BAR}, '<', $filename or die;

===
--- dscr: allow std handles
--- failures: 0
--- params:
--- input
open STDIN, '<', $filename or die;
open STDOUT, '>', $filename or die;
open STDERR, '>', $filename or die;

===
--- dscr: allow std globs in blocks
--- failures: 0
--- params:
--- input
open {*STDIN}, '<', $filename or die;
open {*STDOUT}, '>', $filename or die;
open {*STDERR}, '>', $filename or die;

===
--- dscr: config - pass at default
--- failures: 0
--- params:
--- input
open my $fh1, '<', $filename;
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
close $fh1;

===
--- dscr: config - fail at one after default
--- failures: 1
--- params:
--- input
open my $fh1, '<', $filename;
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
close $fh1;

===
--- dscr: config - set lines to 2
--- failures: 1
--- params: {require_brief_open => {lines => '2'}}
--- input
open my $fh1, '<', $filename;
# 1
close $fh1;

open my $fh2, '<', $filename;
# 1
# 2
close $fh2;

===
--- dscr: nested sub
--- failures: 1
--- params:
--- input
open my $fh1, '<', $filename;
sub not_a_recommended_idiom {
    close $fh1;
}

===
--- dscr: opener sub
--- failures: 0
--- params:
--- input
sub my_open {
    my ($filename) = @_;
    open my $fh1, '<', $filename or return;
    return $fh1;
}

===
--- dscr: long opener sub failure
--- failures: 1
--- params:
--- input
sub my_open {
    my ($filename) = @_;
    open my $fh1, '<', $filename or return;
    # 1
    # 2
    # 3
    # 4
    # 5
    # 6
    # 7
    # 8
    # 9
    return $fh1;
}

===
--- dscr: opener sub failure
--- failures: 1
--- params:
--- input
sub my_open {
    my ($filename) = @_;
    open my $fh1, '<', $filename or return;
    return $fh2;
}

===
--- dscr: unusual lexical syntax
--- failures: 1
--- params:
--- input
## TODO we do not recognize parenthesized lexical declarations
open my ($fh1), '<', $filename;

===
--- dscr: code coverage - unsupported open() calls
--- failures: 0
--- params:
--- input
$self->open($door);
# open($fh); # erroneous call
open(get_fh(), '<', $filename); # first arg returns a filehandle -- bad form
open(1 + 1, '<', $filename); # nonsense

===
--- dscr: code coverage - glob topic for method call
--- failures: 1
--- params:
--- input
open FH1, '<', $filename;
FH1->close; # invalid code

===
--- dscr: code coverage - close is not a function or method call
--- failures: 1
--- params:
--- input
open my $fh, '<', $filename;
$hash->{close};

===
--- dscr: code coverage - FH is not a glob or scalar
--- failures: 0
--- params:
--- input
open @foo, '<', $filename; # nonsense
open @$foo, '<', $filename; # nonsense
open my @bar, '<', $filename; # nonsense

===
--- dscr: CORE::close() - RT #52391
--- failures: 0
--- params:
--- input
open( my $fh, '<', $filename );
my $value = <$fh>;
CORE::close($fh);

===
--- dscr: CORE::GLOBAL::close()
--- failures: 0
--- params:
--- input
open my $fh, '<', $filename;
my $value = <$fh>;
CORE::GLOBAL::close($fh);

===
--- dscr: CORE::open()
--- failures: 1
--- params:
--- input
CORE::open my $fh, '<', $filename;

===
--- dscr: CORE::GLOBAL::open()
--- failures: 1
--- params:
--- input
CORE::GLOBAL::open(my $fh, '<', $filename);

===
--- dscr: Handle declared in outer scope RT #64437
--- failures: 0
--- params:
--- input
#!/usr/bin/perl

my $file = 'fubar';
my ($fh, @lines);

if (! open $fh, '<', $file) {
    croak "Error opening $file for reading: $!";
}
@lines = <$fh>;
if (! close $fh) {
    croak "Error closing $file after reading: $!";
}

