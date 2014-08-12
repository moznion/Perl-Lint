package Perl::Lint::Policy::RegularExpressions::ProhibitUnusualDelimiters;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use only "//" or "{}" to delimit regexps',
    EXPL => [246],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $does_allow_all_brackets = $args->{prohibit_unusual_delimiters}->{allow_all_brackets};

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if (
            $token_type == REG_DELIM &&
            $token_data ne '{' &&
            $token_data ne '}' &&
            $token_data ne '/'
        ) {
            if ($does_allow_all_brackets) {
                if (
                    $token_data eq '(' || $token_data eq ')' ||
                    $token_data eq '[' || $token_data eq ']' ||
                    $token_data eq '<' || $token_data eq '>'
                ) {
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

            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                last if $token_type == SEMI_COLON;
            }
        }
    }

    return \@violations;
}

1;

