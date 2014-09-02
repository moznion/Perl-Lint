package Perl::Lint::Policy::RegularExpressions::ProhibitSingleCharAlternation;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use [%s] instead of %s',
    EXPL => [265],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == REG_EXP) {
            if (my @groups = $token_data =~ /\( \?\: \s* (.+?) \s* \)/gx) {
                TRAVERSE_REGEX: for my $group (@groups) {
                    if ($group =~ /\A \w \Z/x) {
                        last;
                    }

                    my @singles;
                    for my $part (split /\s* \| \s*/x, $group) {
                        if ($part !~ /\A \w+ \Z/x) {
                            last TRAVERSE_REGEX;
                        }

                        if (length $part == 1) { # if single char
                            push @singles, $part;
                        }
                    }

                    if (scalar @singles > 1) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => sprintf(
                                DESC,
                                join('',  @singles),
                                join('|', @singles),
                            ),
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

