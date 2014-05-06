use strict;
my $foo = 1 for @bar;
our $foo = 1 for @bar;

my ($foo, $baz) = @list for @bar;
our ($foo, $baz) = 1 for @bar;
