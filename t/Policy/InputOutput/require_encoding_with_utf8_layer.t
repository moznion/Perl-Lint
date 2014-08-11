use strict;
use warnings;
use Perl::Lint::Policy::InputOutput::RequireEncodingWithUTF8Layer;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'InputOutput::RequireEncodingWithUTF8Layer';

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
--- dscr: basic failures
--- failures: 33
--- params:
--- input
open $fh, ">:utf8", $output;
open($fh, ">:utf8", $output);
open($fh, ">:utf8", $output) or die;

open my $fh, ">:utf8", $output;
open(my $fh, ">:utf8", $output);
open(my $fh, ">:utf8", $output) or die;

open FH, ">:utf8", $output;
open(FH, ">:utf8", $output);
open(FH, ">:utf8", $output) or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open FH, ">:utf8", $output or die;
open $fh, ">:utf8", $output or die;
open my $fh, ">:utf8", $output or die;

# Other file modes
open $fh, "<:utf8", $output;
open $fh, ">>:utf8", $output;
open $fh, "+>:utf8", $output;
open $fh, "+<:utf8", $output;
open $fh, "+>>:utf8", $output;

# binmode()

binmode $fh, ":utf8";
binmode($fh, ":utf8");
binmode($fh, ":utf8") or die;

binmode FH, ":utf8";
binmode(FH, ":utf8");
binmode(FH, ":utf8") or die;

#This are tricky because the Critic can't
#tell where the expression really ends
binmode FH, ":utf8" or die;
binmode $fh, ":utf8" or die;

binmode $fh, "utf8";
binmode($fh, "utf8");
binmode($fh, "utf8") or die;

binmode FH, "utf8";
binmode(FH, "utf8");
binmode(FH, "utf8") or die;

#This are tricky because the Critic can't
#tell where the expression really ends
binmode FH, "utf8" or die;
binmode $fh, "utf8" or die;

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
open $fh, ">$output";
open($fh, ">$output");
open($fh, ">$output") or die;

open my $fh, ">$output";
open(my $fh, ">$output");
open(my $fh, ">$output") or die;

open FH, ">$output";
open(FH, ">$output");
open(FH, ">$output") or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open $fh, ">$output" or die;
open my $fh, ">$output" or die;
open FH, ">$output" or die;

open $fh, '>', $output;
open($fh, '>', $output);
open($fh, '>', $output) or die;

open my $fh, '>', $output;
open(my $fh, '>', $output);
open(my $fh, '>', $output) or die;

open FH, '>', $output;
open(FH, '>', $output);
open(FH, '>', $output) or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open $fh, '>', $output or die;
open my $fh, '>', $output or die;
open FH, '>', $output or die;

open $fh, '>:encoding(utf8)', $output;
open($fh, '>:encoding(utf8)', $output);
open($fh, '>:encoding(utf8)', $output) or die;

open my $fh, '>:encoding(utf8)', $output;
open(my $fh, '>:encoding(utf8)', $output);
open(my $fh, '>:encoding(utf8)', $output) or die;

open FH, '>:encoding(utf8)', $output;
open(FH, '>:encoding(utf8)', $output);
open(FH, '>:encoding(utf8)', $output) or die;

#This are tricky because the Critic can't
#tell where the expression really ends
open $fh, '>:encoding(utf8)', $output or die;
open my $fh, '>:encoding(utf8)', $output or die;
open FH, '>:encoding(utf8)', $output or die;

# binmode

binmode $fh;
binmode($fh);
binmode($fh) or die;

binmode FH;
binmode(FH);
binmode(FH) or die;

#This are tricky because the Critic can't
#tell where the expression really ends
binmode $fh or die;
binmode FH or die;

binmode $fh, ':encoding(utf8)';
binmode($fh, ':encoding(utf8)');
binmode($fh, ':encoding(utf8)') or die;

binmode FH, ':encoding(utf8)';
binmode(FH, ':encoding(utf8)');
binmode(FH, ':encoding(utf8)') or die;

#This are tricky because the Critic can't
#tell where the expression really ends
binmode $fh, ':encoding(utf8)' or die;
binmode FH, ':encoding(utf8)' or die;

$foo{open}; # not a function call

