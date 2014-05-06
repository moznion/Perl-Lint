use strict;
my $foo = 1 if $bar;
our $foo = 1 if $bar;

my ($foo, $baz) = @list if $bar;
our ($foo, $baz) = 1 if $bar;
