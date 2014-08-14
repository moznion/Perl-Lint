package Perl::Lint::Policy::RegularExpressions::ProhibitFixedStringMatches;
use strict;
use warnings;
use Perl::Lint::RegexpParser;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use "eq" or hash instead of fixed-pattern regexps',
    EXPL => [271, 272],
};

my %fixed_regexp_families = (
    open   => 1,
    exact  => 1,
    close  => 1,
    group  => 1,
    branch => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $regexp_parser = Perl::Lint::RegexpParser->new;

    my @violations;
    my $is_reg_quoted = 0;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if ($is_reg_quoted) {
                $is_reg_quoted = 0;
                next;
            }

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

            my $is_with_m_opt = 0;
            if ($maybe_regopt) {
                if ($maybe_regopt->{type} == REG_OPT && $maybe_regopt->{data} =~ /m/) {
                    $is_with_m_opt = 1;
                }
            }

            $regexp_parser->parse($token->{data});

            my @anchors;
            my $is_invalid = 1;
            my $iter = $regexp_parser->walker;
            while (my $node = $iter->()) {
                if (my $family = $node->{family}) {
                    if ($family eq 'anchor') {
                        push @anchors, $node->{vis};
                        next;
                    }

                    if ($fixed_regexp_families{$family}) {
                        next;
                    }
                }

                $is_invalid = 0;
                last;
            }

            if ($is_invalid) {
                if (scalar @anchors == 2) {
                    if ($is_with_m_opt) {
                        if ($anchors[0] eq '^' || $anchors[1] eq '$') {
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
        }
        elsif ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
            $is_reg_quoted = 1;
        }
    }

    return \@violations;
}

1;

