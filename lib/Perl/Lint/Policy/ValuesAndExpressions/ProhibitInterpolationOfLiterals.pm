package Perl::Lint::Policy::ValuesAndExpressions::ProhibitInterpolationOfLiterals;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Useless interpolation of literal string',
    EXPL => [51],
};

# TODO integrate duplicated functions

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $prohibit_interpolation_of_literals = $args->{prohibit_interpolation_of_literals};

    # e.g. {allow => 'qq( qq{ qq[ qq/'}}
    my $allow_double_quote_literals = $prohibit_interpolation_of_literals->{allow};
    my @allow_double_quote_literals;
    for my $allowed_literal (split /\s+/, $allow_double_quote_literals || '') {
        $allowed_literal =~ s/\Aqq//;
        push @allow_double_quote_literals, substr $allowed_literal, 0, 1;
    }

    my $allow_if_string_contains_single_quote = $prohibit_interpolation_of_literals->{allow_if_string_contains_single_quote} || 0;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == STRING) {
            if ($allow_if_string_contains_single_quote) {
                if ($token_data =~ /'/) {
                    next;
                }
            }

            # XXX NP? :(
            if ($token_data =~ /(\\*)(?:[\$\@]|\\\w)/) {
                if (length($1) % 2 == 0) { # check escaped or not
                    next;
                }
            }

            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
        elsif ($token_type == REG_DOUBLE_QUOTE) {
            $token = $tokens->[++$i];
            $token_data = $token->{data};

            if (any {$_ eq $token_data} @allow_double_quote_literals) {
                next;
            }

            $token = $tokens->[++$i];
            $token_data = $token->{data};
            if ($allow_if_string_contains_single_quote) {
                if ($token_data =~ /'/) {
                    next;
                }
            }

            # XXX NP? :(
            if ($token_data =~ /(\\*)(?:[\$\@]\S+|\\\w)/) {
                if (length($1) % 2 == 0) { # check escaped or not
                    next;
                }
            }

            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

1;

