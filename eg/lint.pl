#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Perl::Lint qw/lint/;

my $violations = lint($0);
eval "";

use Data::Dumper; warn Dumper($violations);

__END__

