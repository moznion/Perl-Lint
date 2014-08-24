package Perl::Lint::Policy::Variables::RequireNegativeIndices;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Negative array index should be used',
    EXPL => [88],
};

my %var_token_types = (
    &VAR => 1,
    &GLOBAL_VAR => 1,
);

my %array_dereference_token_types = (
    &ARRAY_DEREFERENCE => 1,
    &ARRAY_SIZE_DEREFERENCE => 1,
);

my %array_var_token_types = (
    &ARRAY_VAR => 1,
    &GLOBAL_ARRAY_VAR => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        my $is_reference = 0;
        if ($var_token_types{$token_type} || $token_type == SHORT_SCALAR_DEREFERENCE) {
            my $var_name;
            if ($token_type == SHORT_SCALAR_DEREFERENCE) {
                $token = $tokens->[++$i];
                last if !$token;

                $var_name = $token->{data};
                $is_reference = 1;
            }
            else {
                $var_name = substr($token->{data}, 1);
            }

            $token = $tokens->[++$i];
            last if !$token;

            if ($token->{type} == POINTER) {
                $is_reference = 1;
                $token = $tokens->[++$i];
                last if !$token;
            }

            if ($token->{type} == LEFT_BRACKET) {
                my $nlbracket = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == LEFT_BRACKET) {
                        $nlbracket++;
                        next;
                    }

                    if ($token_type == RIGHT_BRACKET) {
                        last if --$nlbracket <= 0;
                        next;
                    }

                    if (
                        $token_type == ARRAY_SIZE ||
                        ($is_reference && $token_type == SHORT_ARRAY_DEREFERENCE)
                    ) {
                        $token = $tokens->[++$i];
                        last if !$token;

                        $token_type = $token->{type};

                        my $array_size_data;
                        if ($is_reference && $var_token_types{$token_type}) {
                            $array_size_data = substr $token->{data}, 1;
                        }
                        elsif ($token->{type} == KEY) {
                            $array_size_data = $token->{data};
                        }

                        if ($array_size_data) {
                            $array_size_data =~ s/\W.*\Z//; # XXX workaround
                                                            # ref: https://github.com/goccy/p5-Compiler-Lexer/issues/48
                            if ($array_size_data eq $var_name) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                            }
                        }

                        next;
                    }

                    if (
                        $token_type == ARRAY_DEREFERENCE ||
                        ($is_reference && $token_type == ARRAY_SIZE_DEREFERENCE)
                    ) {
                        $token = $tokens->[++$i];
                        last if !$token;
                    } # fall through
                    if (
                        (!$is_reference && $array_var_token_types{$token_type}) ||
                        $array_dereference_token_types{$token_type}
                    ) {
                        ($token_data = substr $token->{data}, 1) =~ s/\W.*\Z//; # XXX workaround
                                                                                # ref: https://github.com/goccy/p5-Compiler-Lexer/issues/48
                        if ($token_data eq $var_name) {
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
                }
            }
        }

    }

    return \@violations;
}

1;

