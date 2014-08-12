package Perl::Lint::Policy::Subroutines::ProhibitAmpersandSigils;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Subroutine called with "&" sigil',
    EXPL => [175],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $is_before_token_function = 0;
    my $is_in_ref = 0;
    my $left_paren_num = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == BIT_AND) {
            my $next_token_type = $tokens->[++$i]->{type};
            if (
                $next_token_type == KEY       ||
                $next_token_type == NAMESPACE ||
                $next_token_type == NAMESPACE_RESOLVER
            ) {
                if (!$is_before_token_function && !$is_in_ref) {
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
        }
        elsif ($token_type == KEY || $token_type == BUILTIN_FUNC || $token_type == GOTO) {
            $is_before_token_function = 1;
        }
        elsif ($token_type == REF) {
            $is_in_ref = 1;
        }
        elsif ($token_type == LEFT_PAREN) {
            $left_paren_num++;
        }
        elsif ($token_type == RIGHT_PAREN) {
            $left_paren_num--;
            if ($left_paren_num <= 0) {
                $is_in_ref = 0;
            }
        }
        else {
            if ($left_paren_num <= 0) {
                $is_in_ref = 0;
            }
            $is_before_token_function = 0;
        }
    }

    return \@violations;
}

1;

