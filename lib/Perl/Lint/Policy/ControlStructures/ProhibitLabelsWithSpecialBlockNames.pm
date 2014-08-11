package Perl::Lint::Policy::ControlStructures::ProhibitLabelsWithSpecialBlockNames;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Special block name used as label',
    EXPL => 'Use a label that cannot be confused with BEGIN, END, CHECK, INIT, or UNITCHECK blocks',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == MOD_WORD) {
            if ($tokens->[++$i]->{type} == COLON) {
                if ($tokens->[++$i]->{type} == LEFT_BRACE) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
        }
    }

    return \@violations;
}

1;

