use strict;
my $foo = 1 foreach @bar;
our $foo = 1 foreach @bar;

my ($foo, $baz) = @list foreach @bar;
our ($foo, $baz) = 1 foreach @bar;
