use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitUselessTopic;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitUselessTopic';

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
--- dscr: Topics in a filetest
--- failures: 2
--- params:
--- input
my $x = -s $_;
if ( -f $_ ) { foo(); }

===
--- dscr: Topics in a filetest: -t $_ is not useless because -t defaults to STDIN
--- failures: 0
--- params:
--- input
if ( -t $_ ) { foo(); }

===
--- dscr: Topics in a function call, with parens
--- failures: 5
--- params:
--- input
my $x = length($_);
my $y = sin($_);
my $z = defined($_);
my @x = split( /\t/, $_ );
unlink($_);
# Policy cannot handle this yet.
#my $backwards = reverse($_);

===
--- dscr: Topics in a function call, no parens
--- failures: 6
--- params:
--- input
my $x = length $_;
my $y = sin $_;
my $z = defined $_;
my @x = split /\t/, $_;
unlink $_;
my $backwards = reverse $_;

===
--- dscr: Function calls with $_ but in ways that should not be flagged.
--- failures: 0
--- params:
--- input
my @y = split( /\t/, $_, 3 );
my @y = split /\t/, $_, 3;
unlink $_ . '.txt';
my $z = sin( $_ * 4 );
my $a = tan $_ + 5;

my @backwards = reverse $_;
my @backwards = reverse($_);

