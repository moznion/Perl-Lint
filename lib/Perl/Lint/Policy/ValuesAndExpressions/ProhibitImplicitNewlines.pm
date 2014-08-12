package Perl::Lint::Policy::ValuesAndExpressions::ProhibitImplicitNewlines;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Literal line breaks in a string',
    EXPL => [60, 61],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if (
            $token_type == STRING     ||
            $token_type == RAW_STRING ||
            $token_type == REG_EXP
        ) {
            my $string = $token->{data};
            if ($string =~ /\r?\n/) {
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

    return \@violations;
}

1;

