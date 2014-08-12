package Perl::Lint::Policy::ValuesAndExpressions::ProhibitEmptyQuotes;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Quotes used with a string containing no non-whitespace characters',
    EXPL => [53],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == STRING || $token_type == RAW_STRING) {
            my $string = $token->{data};
            if (!$string || $string =~ /\A\s+\Z/) {
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

