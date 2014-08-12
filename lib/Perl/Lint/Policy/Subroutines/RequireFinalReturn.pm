package Perl::Lint::Policy::Subroutines::RequireFinalReturn;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use List::Util qw/any/;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'The additional subroutines to treat as terminal',
    EXPL => [197],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @terminal_funcs = split(/ /, $args->{require_final_return}->{terminal_funcs} || '');

    my @violations;
    my $is_in_sub   = 0;
    my $left_brace_num = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == FUNCTION_DECL) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == LEFT_BRACE) {
                    if ($tokens->[$i+1]->{type} == RIGHT_BRACE) {
                        last;
                    }

                    my $left_brace_num = 1;
                    my $is_returned = 0;
                    my $is_returned_in_cond = undef;
                    my %constant_loop;
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        my $token_data = $token->{data};

                        if ($token_type == LEFT_BRACE) {
                            $left_brace_num++;
                        }
                        elsif ($token_type == RIGHT_BRACE) {
                            delete $constant_loop{$left_brace_num};
                            if (--$left_brace_num <= 0) {
                                if (!$is_returned && !$is_returned_in_cond) {
                                    push @violations, {
                                        filename => $file,
                                        line     => $token->{line},
                                        description => DESC,
                                        explanation => EXPL,
                                        policy => __PACKAGE__,
                                    };
                                }
                                last;
                            }
                        }
                        elsif (
                            $token_type == IF_STATEMENT    ||
                            $token_type == ELSIF_STATEMENT ||
                            $token_type == ELSE_STATEMENT  ||
                            $token_type == UNLESS_STATEMENT
                        ) {
                            $is_returned_in_cond //= 1; # at once

                            my $left_brace_num = 0;
                            my $is_returned_in_cond_locally = 0;
                            for ($i++; $token = $tokens->[$i]; $i++) {
                                $token_type = $token->{type};
                                $token_data = $token->{data};
                                if ($token_type == LEFT_BRACE) {
                                    $left_brace_num++;
                                }
                                elsif ($token_type == RIGHT_BRACE) {
                                    if (!$is_returned_in_cond_locally) {
                                        $is_returned_in_cond = 0;
                                    }
                                    last;
                                }
                                elsif ($token_type == RETURN || $token_type == GOTO) {
                                    $is_returned_in_cond_locally = 1;
                                }
                                elsif ($token_type == KEY && any {$_ eq $token_data} @terminal_funcs) {
                                    $is_returned_in_cond_locally = 1;
                                }
                            }
                        }
                        elsif (
                            $token_type == FOR_STATEMENT     ||
                            $token_type == FOREACH_STATEMENT ||
                            $token_type == WHILE_STATEMENT   ||
                            $token_type == UNTIL_STATEMENT
                        ) {
                            $constant_loop{$left_brace_num+1} = 1;
                        }
                        elsif ($token_type == RETURN || $token_type == GOTO) {
                            if ($constant_loop{$left_brace_num}) {
                                next;
                            }

                            $is_returned = 1;
                        }
                        elsif ($token_type == BUILTIN_FUNC) {
                            if ($constant_loop{$left_brace_num}) {
                                next;
                            }

                            if (
                                $token_data eq 'die'  ||
                                $token_data eq 'exec' ||
                                $token_data eq 'exit'
                            ) {
                                my $next_token = $tokens->[$i+1];
                                if ($next_token->{kind} == KIND_STMT) {
                                    $i++;
                                    next;
                                }
                                $is_returned = 1;
                            }
                        }
                        elsif ($token_type == KEY) {
                            if ($constant_loop{$left_brace_num}) {
                                next;
                            }

                            if (
                                $token_data eq 'croak'   ||
                                $token_data eq 'confess' ||
                                any {$_ eq $token_data} @terminal_funcs
                            ) {
                                my $next_token = $tokens->[$i+1];
                                if (($next_token->{kind} || -1) == KIND_STMT) {
                                    $i++;
                                    next;
                                }
                                else {
                                    my $next_token = $tokens->[$i+2];
                                    if (($next_token->{kind} || -1) == KIND_STMT) {
                                        $i += 2;
                                        next;
                                    }
                                }
                                $is_returned = 1;
                            }
                            elsif ($token_data eq 'throw') {
                                my $target_token = $tokens->[$i+2];
                                if ($target_token->{kind} == KIND_STMT) {
                                    $i += 2;
                                    next;
                                }
                                $is_returned = 1;
                            }
                        }
                        elsif ($token_type == NAMESPACE && $token_data eq 'Carp') {
                            if ($constant_loop{$left_brace_num}) {
                                next;
                            }

                            my $target_token = $tokens->[$i+2];
                            if ($target_token->{type} == NAMESPACE) {
                                my $target_token_data = $target_token->{data};
                                if ($target_token_data eq 'croak' || $target_token_data eq 'confess') {
                                    $is_returned = 1;
                                }
                            }
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

