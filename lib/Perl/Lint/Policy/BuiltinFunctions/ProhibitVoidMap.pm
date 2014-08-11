package Perl::Lint::Policy::BuiltinFunctions::ProhibitVoidMap;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO REFACTOR!!!

use constant {
    DESC => '"map" used in void context',
    EXPL => 'Use a "for" loop instead',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $is_in_context = 0;
    my $is_before_comma = 0; # XXX to decide context or not
    my $is_in_map = 0;
    my $is_in_ctrl_statement = 0;
    my $left_brace_num = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};
        if ($token_type == BUILTIN_FUNC) {
            if ($token_data eq 'map') {
                next if $is_in_map;

                if ($is_in_ctrl_statement) {
                    if ($left_brace_num) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                elsif (!$is_in_context && !$is_before_comma) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }

                $is_in_map = 1;
                next;
            }
            $is_in_context = 1;
        }
        elsif ($token_type == ASSIGN) {
            $is_in_context = 1;
        }
        elsif ( # NOTE enough?
            $token_type == IF_STATEMENT    ||
            $token_type == FOR_STATEMENT   ||
            $token_type == WHILE_STATEMENT ||
            $token_type == UNLESS_STATEMENT
        ) {
            $is_in_ctrl_statement = 1;
        }
        elsif ($is_in_ctrl_statement) {
            if ($token_type == LEFT_BRACE) {
                $left_brace_num++;
            }
            elsif ($token_type == RIGHT_BRACE) {
                $left_brace_num--;
                if ($left_brace_num <= 0) {
                    $is_in_ctrl_statement = 0;
                    $is_in_map = 0;
                }
            }
        }
        elsif ($token_type == SEMI_COLON) {
            $is_in_context = 0;
            $is_in_map     = 0;
        }
        elsif ($token_type == COMMA) {
            $is_before_comma = 1;
        }
        else {
            $is_before_comma = 0;
        }
    }

    return \@violations;
}

1;

