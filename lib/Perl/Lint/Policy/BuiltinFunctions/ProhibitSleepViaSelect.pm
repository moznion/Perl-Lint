package Perl::Lint::Policy::BuiltinFunctions::ProhibitSleepViaSelect;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"select" used to emulate "sleep"',
    EXPL => [168],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'select') {
            my $left_paren_num = 1;
            my $comma_num = 0;
            my $is_on_some_IO = 0;
            my $last_arg = '';

            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            my $last_arg_type = $last_arg->{type};
                            if (!$is_on_some_IO && $comma_num == 3 && ($last_arg_type == DOUBLE || ($last_arg_type != DEFAULT && $last_arg->{kind} == KIND_TERM))) {
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
                    elsif ($token_type == COMMA) {
                        $comma_num++;
                    }
                    else {
                        if ($comma_num < 3 && $token_type != DEFAULT) {
                            $is_on_some_IO = 1;
                        }
                        $last_arg = $token;
                    }
                }
            }
            else {
                for (; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        if (--$left_paren_num <= 0) {
                            my $last_arg_type = $last_arg->{type};
                            if (!$is_on_some_IO && $comma_num == 3 && ($last_arg_type == DOUBLE || ($last_arg_type != DEFAULT && $last_arg->{kind} == KIND_TERM))) {
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
                    elsif ($token_type == COMMA) {
                        $comma_num++;
                    }
                    else {
                        if ($comma_num < 3 && $token_type != DEFAULT) {
                            $is_on_some_IO = 1;
                        }
                        $last_arg = $token;
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

