package t::Policy::Util;
use strict;
use warnings;
use Perl::Lint;
use File::Temp qw/tempfile/;
use parent qw/Exporter/;
our @EXPORT_OK = qw/fetch_violations/;

sub fetch_violations {
    my ($class, $input, $args) = @_;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh $input;
    close $fh;

    my $linter = Perl::Lint->new($args);
    $linter->{site_policies} = ["Perl::Lint::Policy::$class"];
    return $linter->lint($filename);
}

1;

