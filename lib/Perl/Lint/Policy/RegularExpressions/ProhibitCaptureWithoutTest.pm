package Perl::Lint::Policy::RegularExpressions::ProhibitCaptureWithoutTest;
use strict;
use warnings;
use List::Util qw/none/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Capture variable used outside conditional',
    EXPL => [253],
};

my %transfer_of_control_stmt_token_types = (
    &NEXT   => 1,
    &LAST   => 1,
    &REDO   => 1,
    &GOTO   => 1,
    &RETURN => 1,
);

my %control_stmt_token_types = (
    &IF_STATEMENT     => 1,
    &ELSIF_STATEMENT  => 1,
    &UNLESS_STATEMENT => 1,
    &WHILE_STATEMENT  => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my %exceptions = (
        die     => 1,
        croak   => 1,
        confess => 1,
    );

    if (my $this_policies_arg = $args->{prohibit_capture_without_test}) {
        for my $exception (split(/\s+/,  $this_policies_arg->{exception_source} || '')) {
            $exceptions{$exception} = 1;
        };
    }

    my @violations;
    my @is_tested_by_depth;
    my $is_in_context_to_assign = 0;
    my $depth = 0;
    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
            # skip reg quotes (because it is recognized as regexp)
            $i += 2;
            next;
        }

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            $is_tested_by_depth[$depth] = $is_in_context_to_assign ? 1 : 0;

            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == SEMI_COLON) {
                    goto END_OF_STATEMENT;
                }
                elsif (
                    $token_type == THREE_TERM_OP
                ) {
                    $is_tested_by_depth[$depth] = 1;
                    last;
                }
                elsif (
                    $token_type == OR ||
                    $token_type == ALPHABET_OR
                ) {
                    $token = $tokens->[++$i] or last;
                    $token_type = $token->{type};
                    $token_data = $token->{data};

                    if (
                        ($exceptions{$token_data} && $token_type == KEY || $token_type == BUILTIN_FUNC) ||
                        $transfer_of_control_stmt_token_types{$token_type}
                    ) {
                        $is_tested_by_depth[$depth] = 1;
                        last;
                    }

                    $token = $tokens->[++$i] or last;
                    if ($token->{type} == POINTER) {
                        $token = $tokens->[++$i] or last;
                        $token_type = $token->{type};
                        $token_data = $token->{data};
                        if ($exceptions{$token_data} && $token_type == METHOD) {
                            $is_tested_by_depth[$depth] = 1;
                        }
                        last;
                    }

                    last;
                }
            }

            next;
        }

        if ($token_type == SPECIFIC_VALUE && $token_data =~ /\A\$[1-9][0-9]*\Z/) {
            if (none {$_} @is_tested_by_depth) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            next;
        }

        if ($control_stmt_token_types{$token_type}) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $lpnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                    }
                    elsif ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
                        $is_tested_by_depth[$depth + 1] = 1;
                    }
                }

                next;
            }

            # for postfix
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
                    $is_tested_by_depth[$depth + 1] = 1;
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
            next;
        }

        if ($token_type == LEFT_BRACE) {
            $is_tested_by_depth[++$depth] ||= 0;
            next;
        }

        if ($token_type == RIGHT_BRACE) {
            pop @is_tested_by_depth;
            $depth--;
            next;
        }

        if ($token_type == ASSIGN) {
            $is_in_context_to_assign = 1;
            next;
        }

        END_OF_STATEMENT:
        if ($token_type == SEMI_COLON) {
            $is_in_context_to_assign = 0;
            next;
        }
    }

    return \@violations;
}

1;

