package Perl::Lint::Policy::Modules::ProhibitExcessMainComplexity;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant DEFAULT_MAX_MCCABE => 20;

use constant {
    DESC => 'The maximum complexity score allowed',
    EXPL => 'Consider refactoring',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_mccabe = $args->{prohibit_excess_main_complexity}->{max_mccabe} || DEFAULT_MAX_MCCABE;

    my @violations;
    my $mccabe = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

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
            $token_type == LEFT_SHIFT_EQUAL ||
            $token_type == RIGHT_SHIFT_EQUAL
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
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

