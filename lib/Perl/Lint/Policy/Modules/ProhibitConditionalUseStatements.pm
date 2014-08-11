package Perl::Lint::Policy::Modules::ProhibitConditionalUseStatements;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Keywords;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Conditional "use" statement',
    EXPL => 'Use "require" to conditionally include a module',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $is_in_cond  = 0;
    my $is_in_if    = 0;
    my $is_in_do    = 0;
    my $is_in_BEGIN = 0;
    my $left_brace_num = 0;
    my $is_in_illegal_do = 0;
    my $previous_violation;
    for (my $i = 0, my $next_token, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        $token_type = $token->{type};
        $token_data = $token->{data};

        if (
            $token_type == UNLESS_STATEMENT  ||
            $token_type == ELSE_STATEMENT    ||
            $token_type == ELSIF_STATEMENT   ||
            $token_type == WHILE_STATEMENT   ||
            $token_type == UNTIL_STATEMENT   ||
            $token_type == FOR_STATEMENT     ||
            $token_type == FOREACH_STATEMENT ||
            $token_type == CONTINUE ||
            ($token_type == BUILTIN_FUNC && $token_data eq 'eval')
        ) {
            $is_in_cond = 1;
            next;
        }
        elsif (
            ($token_type == AND || $token_type == OR || $token_type == ALPHABET_OR || $token_type == ALPHABET_AND) && $next_token->{type} == DO
        ) {
            $is_in_illegal_do = 1;
            $i++;
            $next_token = undef;
        }
        elsif ($token_type == DO) {
            $is_in_do = 1;
        }
        elsif ($token_type == IF_STATEMENT) {
            $is_in_if = 1;
        }
        elsif ($token_type == MOD_WORD && $token_data eq 'BEGIN') {
            $is_in_BEGIN = 1;
        }
        elsif ($token_type == LEFT_BRACE) {
            $left_brace_num++;
        }
        elsif ($token_type == RIGHT_BRACE) {
            if (--$left_brace_num == 0) {
                my $next_token_type = $next_token->{type};
                if (
                    $is_in_do && $next_token_type &&
                    (
                        $next_token_type eq IF_STATEMENT     ||
                        $next_token_type eq FOR_STATEMENT    ||
                        $next_token_type eq WHILE_STATEMENT  ||
                        $next_token_type eq UNTIL_STATEMENT  ||
                        $next_token_type eq UNLESS_STATEMENT ||
                        $next_token_type eq FOREACH_STATEMENT
                    )
                ) {
                    push @violations, $previous_violation if $previous_violation;
                }
                $is_in_cond = 0;
                $is_in_BEGIN = 0;
                $is_in_if = 0;
                $is_in_do = 0;
                $is_in_illegal_do = 0;
                $previous_violation = undef;
            }
        }
        elsif ($is_in_cond || $is_in_illegal_do || $is_in_do || ($is_in_BEGIN && $is_in_if)) {
            if ($token_type == USE_DECL) {
                my $next_token_type = $next_token->{type};
                if (
                    $next_token_type == NAMESPACE ||
                    ($next_token_type == USED_NAME && !is_perl_pragma($next_token->{data}))
                ) {
                    $previous_violation = {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    if (!$is_in_do) {
                        push @violations, $previous_violation;
                    }
                }
            }
        }
    }

    return \@violations;
}

# TODO support post conditional notation

1;

