package Perl::Lint::Policy::Subroutines::ProhibitManyArgs;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Too many arguments',
    EXPL => [182],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_arguments = $args->{prohibit_many_args}->{max_arguments} || 5;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == FUNCTION_DECL) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == LEFT_BRACE) {
                    my $left_brace_num = 1;
                    my $num_of_vers = 0;
                    my $num_of_vers_per_one_line = 0;
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};

                        if ($token_type == LEFT_BRACE) {
                            $left_brace_num++;
                        }
                        elsif ($token_type == RIGHT_BRACE) {
                            if (--$left_brace_num <= 0) {
                                if ($num_of_vers > $max_arguments) {
                                    push @violations, {
                                        filename => $file,
                                        line     => $token->{line}, # TODO
                                        description => DESC,
                                        explanation => EXPL,
                                        policy => __PACKAGE__,
                                    };
                                }
                                last;
                            }
                        }
                        elsif (
                            $token_type == VAR              ||
                            $token_type == LOCAL_VAR        ||
                            $token_type == GLOBAL_VAR       ||
                            $token_type == ARRAY_VAR        ||
                            $token_type == LOCAL_ARRAY_VAR  ||
                            $token_type == GLOBAL_ARRAY_VAR ||
                            $token_type == HASH_VAR         ||
                            $token_type == LOCAL_HASH_VAR   ||
                            $token_type == GLOBAL_HASH_VAR
                        ) {
                            if ($left_brace_num == 1) { # XXX
                                $num_of_vers_per_one_line++;
                            }
                        }
                        elsif ($token_type == ASSIGN) {
                            my $next_token = $tokens->[$i+1];
                            my $next_token_type = $next_token->{type};
                            my $next_token_data = $next_token->{data};

                            if (
                                $next_token_type == ARGUMENT_ARRAY ||
                                ($next_token_type == BUILTIN_FUNC && $next_token_data eq 'shift')
                            ) {
                                $num_of_vers += $num_of_vers_per_one_line;
                            }
                        }
                        elsif ($token_type == SEMI_COLON) {
                            $num_of_vers_per_one_line = 0;
                        }
                    }
                }
                elsif ($token_type == PROTOTYPE) {
                    (my $prototype = $token->{data}) =~ s/[ ;]//g;
                    $prototype =~ s/\\\[.+?\]/1/g; # XXX
                    if (length $prototype > $max_arguments) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line}, # TODO
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                        last;
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

