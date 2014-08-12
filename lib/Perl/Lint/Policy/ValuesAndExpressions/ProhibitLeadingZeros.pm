package Perl::Lint::Policy::ValuesAndExpressions::ProhibitLeadingZeros;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Don't allow any leading zeros at all.  Otherwise builtins that deal with Unix permissions, e.g. chmod, don't get flagged.},
    EXPL => [58],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $is_strict = $args->{prohibit_leading_zeros}->{strict} || 0;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if (!$is_strict && $token_type == BUILTIN_FUNC) {
            # skip the first argument of chmod()
            if ($token_data eq 'chmod') {
                if ($tokens->[++$i]->{type} == LEFT_PAREN) {
                    $i++;
                }
                next;
            }

            # skip third argument of dbmopen()
            if ($token_data eq 'dbmopen') {
                if ($tokens->[++$i]->{type} == LEFT_PAREN) {
                    $i++;
                }

                my $comma_num = 0;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == SEMI_COLON) {
                        last;
                    }

                    if ($token_type == COMMA) {
                        $comma_num++;
                    }

                    if ($comma_num == 2) {
                        $i++;
                        last;
                    }
                }
                next;
            }

            # skip second argument of mkdir()
            if ($token_data eq 'mkdir') {
                if ($tokens->[++$i]->{type} == LEFT_PAREN) {
                    $i++;
                }

                my $comma_num = 0;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == SEMI_COLON) {
                        last;
                    }

                    if ($token_type == COMMA) {
                        $comma_num++;
                    }

                    if ($comma_num == 1) {
                        $i++;
                        last;
                    }
                }
                next;
            }

            # skip the first argument of umask()
            if ($token_data eq 'umask') {
                if ($tokens->[++$i]->{type} == LEFT_PAREN) {
                    $i++;
                }
                next;
            }
        }

        if (!$is_strict && $token_type == KEY) {
            # skip the fourth argument of sysopen()
            if ($token_data eq 'sysopen') {
                if ($tokens->[++$i]->{type} == LEFT_PAREN) {
                    $i++;
                }

                my $comma_num = 0;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == SEMI_COLON) {
                        last;
                    }

                    if ($token_type == COMMA) {
                        $comma_num++;
                    }

                    if ($comma_num == 3) {
                        $i++;
                        last;
                    }
                }
                next;
            }
        }

        if ($token_type == INT && $token_data != 0 && $token_data =~ /\A-?0/) {
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
            next;
        }
    }

    return \@violations;
}

1;

