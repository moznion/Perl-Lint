package t::Evaluate::Util;
use strict;
use warnings;
use Perl::Lint;
use parent qw/Exporter/;
our @EXPORT_OK = qw/fetch_violations/;

sub fetch_violations {
    my ($file, $class) = @_;

    my $tokens     = Perl::Lint::_tokenize($file);
    my $violations = "Perl::Lint::Evaluator::Variables::$class"->evaluate($file, $tokens);
}

1;

