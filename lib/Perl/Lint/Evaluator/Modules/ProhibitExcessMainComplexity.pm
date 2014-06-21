package Perl::Lint::Evaluator::Modules::ProhibitExcessMainComplexity;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

use constant DEFAULT_MAX_MCCABE => 20;

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_mccabe = $args->{prohibit_excess_main_complexity}->{max_mccabe} || DEFAULT_MAX_MCCABE;

    my @violations;
    my $mccabe = 0;
    my $next_token;
    for (my $i = 0; my $token = $next_token || $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        my $token_type = $token->{type};
        my $_next_token = $next_token;
        my $next_token_type = $_next_token->{type};

        my $left_brace_num = 0;
        if ($token_type == FUNCTION_DECL) {
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                if ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    if (--$left_brace_num < 0) {
                        last;
                    }
                }
            }
        }
        elsif (
            $token_type == AND ||
            $token_type == OR ||
            $token_type == ALPHABET_AND ||
            $token_type == ALPHABET_OR ||
            $token_type == ALPHABET_XOR ||
            $token_type == OR_EQUAL ||
            $token_type == AND_EQUAL ||
            $token_type == THREE_TERM_OP ||
            $token_type == IF_STATEMENT ||
            $token_type == ELSIF_STATEMENT ||
            $token_type == ELSE_STATEMENT ||
            $token_type == UNLESS_STATEMENT ||
            $token_type == WHILE_STATEMENT ||
            $token_type == UNTIL_STATEMENT ||
            $token_type == FOR_STATEMENT ||
            $token_type == FOREACH_STATEMENT ||
            (($token_type == RIGHT_SHIFT || $token_type == LEFT_SHIFT) && $next_token_type && $next_token_type == ASSIGN)
        ) {
            $mccabe++;
        }
    }

    if ($mccabe > $max_mccabe) {
        push @violations, {
            filename => $file,
            line     => 1,
            description => DESC,
            explanation => EXPL,
        };
    }

    return \@violations;
}

1;

