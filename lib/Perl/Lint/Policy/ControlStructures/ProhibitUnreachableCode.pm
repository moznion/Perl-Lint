package Perl::Lint::Policy::ControlStructures::ProhibitUnreachableCode;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Unreachable code',
    EXPL => 'Consider removing it',
};

my %control_statement_token_types_to_exit = (
    &RETURN => 1,
    &NEXT   => 1,
    &LAST   => 1,
    &REDO   => 1,
);

my %control_statement_to_exit = (
    die     => 1,
    exit    => 1,
    croak   => 1,
    confess => 1,
);

my %conditional_token_types = (
    &AND          => 1,
    &OR           => 1,
    &ALPHABET_AND => 1,
    &ALPHABET_OR  => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $depth = 0;
    my %is_exited_by_depth;
    my %unreachable_token_by_depth;
    my %is_in_ignore_context_by_depth;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == LEFT_BRACE) {
            $depth++;
            next;
        }

        if ($token_type == RIGHT_BRACE) {
            if (my $unreachable_token = $unreachable_token_by_depth{$depth}) {
                push @violations, {
                    filename => $file,
                    line     => $unreachable_token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };

                undef $unreachable_token_by_depth{$depth};
            }

            $is_exited_by_depth{$depth}   = 0;
            $is_in_ignore_context_by_depth{$depth} = 0;
            $depth--;
            next;
        }

        if (
            (($token_type == KEY || $token_type == BUILTIN_FUNC) && $control_statement_to_exit{$token_data}) ||
            $control_statement_token_types_to_exit{$token_type}
        ) {
            if ($is_exited_by_depth{$depth}) {
                $unreachable_token_by_depth{$depth} //= $token;
                next;
            }

            my $before_token = $tokens->[$i-1];
            if ($conditional_token_types{$before_token->{type}} ||
                ($before_token->{type} == DEFAULT_OP && $before_token->{data} eq '//')
            ) {
                # if before token is conditional operator, ignore
                next;
            }

            $is_exited_by_depth{$depth} = 1;

            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == SEMI_COLON) {
                    last;
                }

                if ($token_type == IF_STATEMENT || $token_type == UNLESS_STATEMENT) {
                    # if postfix conditional statement exists, ignore
                    $is_exited_by_depth{$depth} = 0;
                    last;
                }
            }

            next;
        }

        if ($token_type == KEY) {
            $token = $tokens->[++$i];
            if ($token->{type} == COLON) {
                # Label (e.g. FOO:)
                $is_in_ignore_context_by_depth{$depth} = 1;
            }

            next;
        }

        if ($token_type == PACKAGE) {
            # in other package
            $is_in_ignore_context_by_depth{$depth} = 1;
            next;
        }

        if (
            $token_type == USE_DECL || $token_type == OUR_DECL ||
            ($token_type == BUILTIN_FUNC && $token_data eq 'no')
        ) {
            # for compiler phase. Ignore them.
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == SEMI_COLON) {
                    last;
                }
            }
            next;
        }

        if (
            $token_type == FUNCTION_DECL ||
            ($token_type == MOD_WORD && $token_data eq 'BEGIN')
        ) {
            # for function declare and BEGIN block
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == LEFT_BRACE) {
                    last;
                }
            }

            $i--; # rewind

            next;
        }

        if ($is_exited_by_depth{$depth} && !$is_in_ignore_context_by_depth{$depth}) {
            $unreachable_token_by_depth{$depth} //= $token;
        }
    }

    # for depth of top, finally
    if (my $unreachable_token = $unreachable_token_by_depth{$depth}) {
        push @violations, {
            filename => $file,
            line     => $unreachable_token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

