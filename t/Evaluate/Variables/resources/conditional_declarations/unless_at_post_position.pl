use strict;
my $foo = 1 unless $bar;
our $foo = 1 unless $bar;
my ($foo, $baz) = @list unless $bar;
our ($foo, $baz) = 1 unless $bar;
