package Perl::Lint::Evaluator::Modules::ProhibitMultiplePackages;
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
    my $had_declared_package = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == PACKAGE) {
             unless ($had_declared_package) {
                 $had_declared_package = 1;
                 next;
             }

            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
            };
        }
    }

    return \@violations;
}

1;

