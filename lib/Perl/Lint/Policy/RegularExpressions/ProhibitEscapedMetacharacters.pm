package Perl::Lint::Policy::RegularExpressions::ProhibitEscapedMetacharacters;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use character classes for literal metachars instead of escapes',
    EXPL => [247],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type, my $is_reg_quote; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if ($is_reg_quote) {
                $is_reg_quote = 0;
                next;
            }

            my $regexp = $token->{data};

            my $maybe_regopt;
            if ($token_type == REG_EXP) {
                $maybe_regopt = $tokens->[$i+2];
            }
            else {
                $maybe_regopt = $tokens->[$i+4];
                if ($maybe_regopt->{type} == REG_DELIM) { # if it use brackets as delimiter
                    $maybe_regopt = $tokens->[$i+5];
                }
            }

            my $regex_to_detect = qr/[{}().*+?|# ]/;
            if ($maybe_regopt->{type} == REG_OPT) {
                if ($maybe_regopt->{data} =~ /x/) {
                    $regex_to_detect = qr/[{}().*+?| ]/;
                }
            }

            if (my @backslashes = $token->{data} =~ /(\\+)$regex_to_detect/g) {
                for my $backslash (@backslashes) {
                    if (length($backslash) % 2 != 0) { # not escaped
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                        last;
                    }
                }
            }
        }
        elsif ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
            $is_reg_quote = 1;
        }
    }

    return \@violations;
}

1;

