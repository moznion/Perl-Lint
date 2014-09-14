package Perl::Lint::Policy::ValuesAndExpressions::ProhibitComplexVersion;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '$VERSION value should not come from outside module',
    EXPL => 'If the version comes from outside the module, you can get everything from unexpected version changes to denial-of-service attacks.',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $forbid_use_version;
    if (my $this_policies_arg = $args->{prohibit_complex_version}) {
        $forbid_use_version = $this_policies_arg->{forbid_use_version};
    }

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == OUR_DECL) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            $token_data = $token->{data};

            my $is_version_assigned = 0;

            if ($token_type == LEFT_PAREN) {
                my $left_paren_num = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_data = $token->{data};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            last;
                        }
                    }
                    elsif (
                        ($token_type == VAR || $token_type == GLOBAL_VAR) &&
                        $token_data eq '$VERSION'
                    ) {
                        $is_version_assigned = 1;
                    }
                }
            }
            elsif (
                ($token_type == VAR || $token_type == GLOBAL_VAR) &&
                $token_data eq '$VERSION'
            ) {
                $is_version_assigned = 1;
            }

            if ($is_version_assigned) {
                $i++; # skip assign symbol

                $token = $tokens->[++$i];
                $token_type = $token->{type};
                $token_data = $token->{data};
                if (
                    $token_type == VAR || $token_type == GLOBAL_VAR
                ) {
                    my $next_token = $tokens->[$i+1];
                    if (
                        ($token_data ne '$VERSION' && $token_data =~ /\A\$[A-Z0-9_]+\Z/) ||
                        $next_token->{type} == NAMESPACE_RESOLVER
                    ) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                elsif ($token_type == STRING) {
                    if ($token_data =~ /\A\$(?:\S+::)+\S+\Z/) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                elsif ($token_type == REG_DOUBLE_QUOTE) {
                    $i++; # skip reg delimiter
                    $token = $tokens->[++$i];
                    if ($token->{data} =~ /\A\$(?:\S+::)+\S+\Z/) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                elsif ($token_type == NAMESPACE) {
                    $token = $tokens->[++$i];
                    if ($token->{type} == NAMESPACE_RESOLVER) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                elsif ($token_type == LEFT_PAREN) {
                    my $left_paren_num = 1;
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }
                        elsif ($token_type == RIGHT_PAREN) {
                            if (--$left_paren_num <= 0) {
                                last;
                            }
                        }
                        elsif ($token_type == NAMESPACE_RESOLVER) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                    }
                }
                elsif ($token_type == DO || ($token_type == BUILTIN_FUNC && $token_data eq 'eval')) {
                    $token = $tokens->[++$i];
                    if ($token->{type} == LEFT_BRACE) {
                        my $left_brace_num = 1;
                        for ($i++; $token = $tokens->[$i]; $i++) {
                            $token_type = $token->{type};
                            if ($token_type == LEFT_BRACE) {
                                $left_brace_num++;
                            }
                            elsif ($token_type == RIGHT_BRACE) {
                                if (--$left_brace_num <= 0) {
                                    last;
                                }
                            }
                            elsif ($token_type == NAMESPACE_RESOLVER) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                            }
                        }
                    }
                }
            }
        }
        elsif ($token_type == USED_NAME && $token_data eq 'version') {
            if ($forbid_use_version) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

