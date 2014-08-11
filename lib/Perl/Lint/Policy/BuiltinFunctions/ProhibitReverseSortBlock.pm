package Perl::Lint::Policy::BuiltinFunctions::ProhibitReverseSortBlock;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Forbid $b before $a in sort blocks',
    EXPL => [152],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'sort') {
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                $token = $tokens->[++$i];
            }

            if ($token->{type} == LEFT_BRACE) {
                my $left_brace_num = 1;
                my $is_b_at_before_comparator = 0;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_data = $token->{data};
                    if ($token_type == COMPARE || $token_type == STRING_COMPARE) {
                        if ($is_b_at_before_comparator) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                    }
                    elsif ($token_type == LEFT_BRACE) {
                        $left_brace_num++;
                    }
                    elsif ($token_type == RIGHT_BRACE) {
                        last if --$left_brace_num <= 0;
                    }
                    elsif ($token_type == VAR && $token_data eq '$b') {
                        $is_b_at_before_comparator = 1;
                    }
                    elsif ( # XXX enough?
                        $token_type == OR  ||
                        $token_type == AND ||
                        $token_type == ALPHABET_OR ||
                        $token_type == ALPHABET_AND
                    ) {
                        $is_b_at_before_comparator = 0;
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

