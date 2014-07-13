package Perl::Lint::Evaluator::ValuesAndExpressions::ProhibitCommaSeparatedStatements;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        # push @violations, {
        #     filename => $file,
        #     line     => $token->{line},
        #     description => DESC,
        #     explanation => EXPL,
        # };
    }

    return \@violations;
}

1;

