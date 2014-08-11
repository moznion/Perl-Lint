package Perl::Lint::Policy::InputOutput::RequireCheckedSyscalls;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use B::Keywords;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Return value of flagged function ignored',
    EXPL => [208, 278],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $is_target_all = 0;
    my @target_functions = qw/open close say/;
    my $allowed_functions;
    if (my $required_checked_syscalls_arg = $args->{require_checked_syscalls}) {
        if (my $functions = $required_checked_syscalls_arg->{functions}) {
            if ($functions eq ':builtins') {
                @target_functions = @B::Keywords::Functions;
            }
            elsif ($functions eq ':all') {
                $is_target_all = 1;
            }
            else {
                @target_functions = ($functions);
            }
        }

        if ($allowed_functions = $required_checked_syscalls_arg->{exclude_functions}) {
            @target_functions = grep {$_ ne $allowed_functions} @target_functions;
        }
    }

    my $is_in_assign_context = 0;
    my $is_in_statement_context = 0;
    my $is_called_syscalls_in_void = 0;
    my $is_enabled_autodie = 0;
    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_kind = $token->{kind};
        my $token_data = $token->{data};

        if ($token_type == ASSIGN) {
            $is_in_assign_context = 1;
            next;
        }

        if ($token_type == USED_NAME) {
            if ($token_data eq 'Fatal') {
                my $next_token = $tokens->[$i+1];
                my $next_token_type = $next_token->{type};
                my $next_token_data = $next_token->{data};
                if ($next_token_type == REG_LIST) {
                    for ($i += 3; my $token = $tokens->[$i]; $i++) {
                        my $token_type = $token->{type};
                        my $token_data = $token->{data};
                        if ($token_type == REG_EXP) {
                            @target_functions = grep {$_ ne $token_data} @target_functions
                        }
                        elsif ($token_type == REG_DELIM) {
                            last;
                        }
                    }
                }
                elsif ($next_token_type == LEFT_PAREN) {
                    my $left_paren_num = 1;
                    for ($i += 2; my $token = $tokens->[$i]; $i++) {
                        my $token_type = $token->{type};
                        my $token_data = $token->{data};
                        if ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }
                        elsif (($token_type == STRING || $token_type == RAW_STRING) && any {$_ eq $token_data} @target_functions) {
                            return [];
                        }
                        else {
                            last if --$left_paren_num <= 0;
                        }
                    }
                }
                elsif (($next_token_type == STRING || $next_token_type == RAW_STRING) && any {$_ eq $next_token_data} @target_functions) {
                    last;
                }
            }
            elsif ($token_data eq 'autodie') {
                if ($tokens->[$i+1]->{type} == REG_LIST) {
                    for ($i += 3; my $token = $tokens->[$i]; $i++) {
                        my $token_type = $token->{type};
                        if ($token_type == REG_EXP && $token->{data} =~ /\A\s*:io\s*\Z/) {
                            $is_enabled_autodie = 1;
                        }
                        elsif ($token_type == REG_DELIM) {
                            last;
                        }
                    }
                }
                else {
                    $is_enabled_autodie = 1;
                }
            }

            next;
        }

        if ($token_type == NAMESPACE && $token_data eq 'Fatal') {
            my $skipped_token = $tokens->[$i+2];
            if ($skipped_token && $skipped_token->{type} == NAMESPACE && $skipped_token->{data} eq 'Exception') {
                for ($i += 3; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    my $token_data = $token->{data};
                    if ($token_type == REG_LIST) {
                        for ($i += 2; my $token = $tokens->[$i]; $i++) {
                            my $token_type = $token->{type};
                            my $token_data = $token->{data};
                            if ($token_type == REG_EXP) {
                                @target_functions = grep {$_ ne $token_data} @target_functions
                            }
                            elsif ($token_type == REG_DELIM) {
                                last;
                            }
                        }
                    }
                    elsif ($token_type == LEFT_PAREN) {
                        my $left_paren_num = 1;
                        for ($i++; my $token = $tokens->[$i]; $i++) {
                            my $token_type = $token->{type};
                            my $token_data = $token->{data};
                            if ($token_type == LEFT_PAREN) {
                                $left_paren_num++;
                            }
                            elsif (($token_type == STRING || $token_type == RAW_STRING) && any {$_ eq $token_data} @target_functions) {
                                return [];
                            }
                            else {
                                last if --$left_paren_num <= 0;
                            }
                        }
                    }
                    elsif (($token_type == STRING || $token_type == RAW_STRING) && any {$_ eq $token_data} @target_functions) {
                        last;
                    }
                    elsif ($token->{kind} == KIND_STMT_END) {
                        last;
                    }
                }
            }

            next;
        }

        if ($token_kind == KIND_STMT) {
            $is_in_statement_context = 1;

            if ($tokens->[$i+1]->{type} == LEFT_PAREN) {
                $i++;
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    else {
                        last if --$left_paren_num <= 0;
                    }
                }
            }
            next;
        }

        if ($token_type == BUILTIN_FUNC || ($is_target_all && $token_type == RETURN)) {
            if ($is_target_all || any {$_ eq $token_data} @target_functions) {
                if (!$is_in_assign_context && !$is_in_statement_context) {
                    $is_called_syscalls_in_void = 1;
                }
            }
            elsif ($token_data eq 'no') {
                my $next_token = $tokens->[++$i];
                if ($next_token->{type} == KEY && $next_token->{data} eq 'autodie') {
                    $is_enabled_autodie = 0;
                }
            }
            next;
        }

        if (
            $is_target_all &&
            ($token_type == CALL || ($token_type == KEY && $tokens->[++$i]->{type} == LEFT_PAREN))
        ) {
            if ($allowed_functions && $token_data =~ /\A$allowed_functions\s*\(?/) {
                next;
            }
            elsif (!$is_in_assign_context && !$is_in_statement_context) {
                $is_called_syscalls_in_void = 1;
            }
            next;
        }

        if ($token_kind == KIND_OP) {
            $is_in_statement_context = 1;
            $is_called_syscalls_in_void = 0;
            next;
        }

        if ($token_kind == KIND_STMT_END) {
            next if $is_enabled_autodie;

            if ($is_called_syscalls_in_void) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            $is_in_assign_context = 0;
            $is_in_statement_context = 0;
            $is_called_syscalls_in_void = 0;
            next;
        }

    }

    return \@violations;
}

1;

