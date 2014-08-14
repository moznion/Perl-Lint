#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Perl::Lint qw/lint/;

my $linter = Perl::Lint->new();
my $violations = $linter->lint($0);
eval "";

use Data::Dumper; warn Dumper($violations);

__END__

