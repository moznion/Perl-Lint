package Perl::Lint::Policy::Subroutines::ProhibitUnusedPrivateSubroutines;
use strict;
use warnings;
use Compiler::Lexer;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Private subroutine/method "%s" declared but not used',
    EXPL => 'Eliminate dead code',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my %allow;
    if (my $allow = $args->{prohibit_unused_private_subroutines}->{allow}) {
        $allow{$_} = 1 for split / /, $allow;
    }
    my $allow_regex = $args->{prohibit_unused_private_subroutines}->{private_name_regex};

    my $lexer;
    my @violations;
    my @private_functions;
    my %ignores;
    my %called;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == FUNCTION_DECL) {
            $token = $tokens->[++$i];
            $token_data = $token->{data};
            if (substr($token_data, 0, 1) eq '_' && !$allow{$token_data}) {
                if (!$allow_regex || $token_data !~ /$allow_regex/) {
                    my $declared_private_function = '';
                    for (; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == NAMESPACE || $token_type == FUNCTION) {
                            $declared_private_function = $token->{data};
                        }
                        elsif ($token_type == NAMESPACE_RESOLVER) {
                            last;
                        }
                        elsif ($token_type == LEFT_BRACE) {
                            push @private_functions, $token_data;

                            my $left_brace_num = 1;
                            for ($i++; $token = $tokens->[$i]; $i++) {
                                $token_type = $token->{type};
                                if ($token_type == LEFT_BRACE) {
                                    $left_brace_num++;
                                }
                                elsif ($token_type == RIGHT_BRACE) {
                                    last if --$left_brace_num <= 0;
                                }
                                elsif ($token_type == CALL || $token_type == KEY || $token_type == METHOD) {
                                    $token_data = $token->{data};
                                    if ($token_data eq $declared_private_function) {
                                        next;
                                    }
                                    $called{$token_data} = 1;
                                }
                            }
                            last;
                        }
                        elsif ($token_type == SEMI_COLON) {
                            last;
                        }
                    }
                }
            }
        }
        elsif ($token_type == CALL || $token_type == KEY || $token_type == METHOD) {
            $called{$token_data} = 1;
        }
        elsif ($token_type == USED_NAME && $token_data eq 'overload') {
            my $is_value = 1;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                my $next_token = $tokens->[$i+1];
                my $next_token_type = $next_token->{type};
                if ($token_type == ARROW) {
                    if ($is_value) {
                        for ($i++; $token = $tokens->[$i]; $i++) {
                            $token_type = $token->{type};
                            if (
                                $token_type == KEY    ||
                                $token_type == STRING ||
                                $token_type == RAW_STRING
                            ) {
                                $ignores{$token->{data}} = 1;
                            }
                            elsif ($token_type == SEMI_COLON) {
                                last; # fail safe
                            }
                        }
                    }
                    $is_value = !$is_value;
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
        }
        elsif ($token_type == REG_REPLACE || $token_type == REG_MATCH) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == REG_REPLACE_TO || $token_type == REG_EXP) {
                    $lexer ||= Compiler::Lexer->new($file);
                    my $replace_to_tokens = $lexer->tokenize($token->{data});

                    for (my $i = 0; $token = $replace_to_tokens->[$i]; $i++) {
                        my $token_type = $token->{type};
                        if ($token_type == CALL || $token_type == KEY || $token_type == METHOD) {
                            $called{$token->{data}} = 1;
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    last; # fail safe
                }
            }
        }
    }

    for my $private_function (@private_functions) {
        if ($ignores{$private_function}) {
            next;
        }

        unless ($called{$private_function}) {
            push @violations, {
                filename => $file,
                line     => 0, # TODO $token->{line},
                description => sprintf(DESC, $private_function),
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

1;

