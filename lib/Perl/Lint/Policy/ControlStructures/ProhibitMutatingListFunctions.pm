package Perl::Lint::Policy::ControlStructures::ProhibitMutatingListFunctions;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Don't modify $_ in list functions},
    EXPL => [114],
};

my %_target_functions = (
    map                 => 1,
    grep                => 1,
    first               => 1,
    any                 => 1,
    all                 => 1,
    none                => 1,
    notall              => 1,
    true                => 1,
    false               => 1,
    firstidx            => 1,
    first_index         => 1,
    lastidx             => 1,
    last_index          => 1,
    insert_after        => 1,
    insert_after_string => 1,
);

my %assigner = (
    &ASSIGN        => 1,
    &POWER_EQUAL   => 1,
    &ADD_EQUAL     => 1,
    &MUL_EQUAL     => 1,
    &AND_BIT_EQUAL => 1,
    &SUB_EQUAL     => 1,
    &DIV_EQUAL     => 1,
    &OR_BIT_EQUAL  => 1,
    &MOD_EQUAL     => 1,
    &NOT_BIT_EQUAL => 1,
    &DEFAULT_EQUAL => 1,
    &AND_EQUAL     => 1,
    &OR_EQUAL      => 1,
    &STRING_ADD_EQUAL  => 1,
    &LEFT_SHIFT_EQUAL  => 1,
    &RIGHT_SHIFT_EQUAL => 1,
);

my %reg_replace_token_types = (
    &REG_REPLACE     => 1,
    &REG_ALL_REPLACE => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my %target_functions = %_target_functions;
    if (my $this_policies_arg = $args->{prohibit_mutating_list_functions}) {
        if (my $list_funcs = $this_policies_arg->{list_funcs}) {
            %target_functions = ();
            $target_functions{$_} = 1 for split /\s+/, $list_funcs;
        }

        if (my $add_list_funcs = $this_policies_arg->{add_list_funcs}) {
            $target_functions{$_} = 1 for split /\s+/, $add_list_funcs;
        }
    }

    my @violations;
    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC || $token_type == KEY) {
            if ($target_functions{$token_data}) {
                $token = $tokens->[++$i] or last;
                if ($token->{type} != LEFT_BRACE) {
                    next;
                }

                my $lbnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_data = $token->{data};

                    if ($token_type == LEFT_BRACE) {
                        $lbnum++;
                    }
                    elsif ($token_type == RIGHT_BRACE) {
                        last if --$lbnum <= 0;
                    }
                    elsif ($token_type == SPECIFIC_VALUE && $token_data eq '$_') {
                        $token = $tokens->[++$i] or last;
                        $token_type = $token->{type};

                        if ($token_type == RIGHT_BRACE) {
                            last if --$lbnum <= 0;
                        }

                        # for assign
                        if (
                            $assigner{$token_type} ||
                            $token_type == PLUSPLUS || $token_type == MINUSMINUS
                        ) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            last;
                        }

                        # for replace by regex
                        if ($token_type == REG_OK) {
                            $token = $tokens->[++$i] or last;
                            $token_type = $token->{type};

                            if ($reg_replace_token_types{$token_type}) {
                                my $is_replace_to_empty = 0;
                                my $is_equal_src_between_dst = 0;

                                my $replace_to;
                                my $replace_from;
                                for ($i++; $token = $tokens->[$i]; $i++) {
                                    $token_type = $token->{type};
                                    if ($token_type == REG_REPLACE_FROM) {
                                        $replace_from = $token->{data};
                                    }
                                    elsif ($token_type == REG_REPLACE_TO) {
                                        $replace_to = $token->{data};
                                        if ($replace_to eq '') {
                                            $is_replace_to_empty = 1;
                                        }
                                        elsif ($replace_to eq $replace_from) {
                                            $is_equal_src_between_dst =1;
                                        }
                                        $i++; # at last reg delim
                                        last;
                                    }
                                }

                                my $is_replaced = !$is_replace_to_empty && !$is_equal_src_between_dst;
                                if ($token = $tokens->[++$i]) {
                                    if ($token->{type} == REG_OPT and my @opts = $token->{data} =~ /([cdrs])/g) {
                                        my %opts = map {$_ => 1} @opts;

                                        if ($opts{r}) {
                                            $is_replaced = 0;
                                        }
                                        else {
                                            if ($opts{c}) {
                                                $is_replaced = $is_equal_src_between_dst;
                                            }

                                            if ($opts{d}) {
                                                $is_replaced = $is_replace_to_empty;
                                            }

                                            if ($opts{s}) {
                                                $is_replaced = $is_replace_to_empty || $is_equal_src_between_dst;
                                            }
                                        }
                                    }
                                }

                                if (!$is_replaced) {
                                    last;
                                }

                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last;
                            }
                        }
                    }
                    elsif ($token_type == PLUSPLUS || $token_type == MINUSMINUS) {
                        $token = $tokens->[++$i] or last;
                        if ($token->{type} == SPECIFIC_VALUE && $token->{data} eq '$_') {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            last;
                        }
                    }
                    elsif ($reg_replace_token_types{$token_type}) {
                        my $before_token = $tokens->[$i-1] or next;
                        if ($before_token->{type} != REG_OK) {
                            my $is_replace_to_empty = 0;
                            my $is_equal_src_between_dst = 0;

                            my $replace_to;
                            my $replace_from;
                            for ($i++; $token = $tokens->[$i]; $i++) {
                                $token_type = $token->{type};
                                if ($token_type == REG_REPLACE_FROM) {
                                    $replace_from = $token->{data};
                                }
                                elsif ($token_type == REG_REPLACE_TO) {
                                    $replace_to = $token->{data};
                                    if ($replace_to eq '') {
                                        $is_replace_to_empty = 1;
                                    }
                                    elsif ($replace_to eq $replace_from) {
                                        $is_equal_src_between_dst =1;
                                    }
                                    $i++; # at last reg delim
                                    last;
                                }
                            }

                            my $is_replaced = !$is_replace_to_empty && !$is_equal_src_between_dst;
                            if ($token = $tokens->[++$i]) {
                                if ($token->{type} == REG_OPT and my @opts = $token->{data} =~ /([cdrs])/g) {
                                    my %opts = map {$_ => 1} @opts;

                                    if ($opts{r}) {
                                        $is_replaced = 0;
                                    }
                                    else {
                                        if ($opts{c}) {
                                            $is_replaced = $is_equal_src_between_dst;
                                        }

                                        if ($opts{d}) {
                                            $is_replaced = $is_replace_to_empty;
                                        }

                                        if ($opts{s}) {
                                            $is_replaced = $is_replace_to_empty || $is_equal_src_between_dst;
                                        }
                                    }
                                }
                            }

                            if (!$is_replaced) {
                                last;
                            }

                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            last;
                        }
                    }
                    elsif ($token_type == KEY || $token_type == BUILTIN_FUNC || $token_type == DEFAULT) {
                        if ($token_data eq 'chop' || $token_data eq 'chomp') {
                            $token = $tokens->[++$i] or last;
                            $token_type = $token->{type};
                            $token_data = $token->{data};
                            if ($token_type == SEMI_COLON || $token_type == RIGHT_BRACE) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last;
                            }
                            elsif ($token_type == SPECIFIC_VALUE && $token_data eq '$_') {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last;
                            }
                            elsif ($token_type == LEFT_PAREN) {
                                $token = $tokens->[++$i] or last;
                                if ($token->{type} == RIGHT_PAREN) {
                                    push @violations, {
                                        filename => $file,
                                        line     => $token->{line},
                                        description => DESC,
                                        explanation => EXPL,
                                        policy => __PACKAGE__,
                                    };
                                    last;
                                }

                                my $lpnum = 1;
                                for (; $token = $tokens->[$i]; $i++) {
                                    $token_type = $token->{type};

                                    if ($token_type == LEFT_PAREN) {
                                        $lpnum++;
                                    }
                                    elsif ($token_type == RIGHT_PAREN) {
                                        last if --$lpnum <= 0;
                                    }
                                    elsif ($token_type == SPECIFIC_VALUE && $token->{data} eq '$_') {
                                        push @violations, {
                                            filename => $file,
                                            line     => $token->{line},
                                            description => DESC,
                                            explanation => EXPL,
                                            policy => __PACKAGE__,
                                        };
                                        last;
                                    }
                                }
                            }
                        }
                        elsif ($token_data eq 'undef') {
                            $token = $tokens->[++$i] or last;
                            $token_type = $token->{type};
                            $token_data = $token->{data};
                            if ($token_type == SPECIFIC_VALUE && $token_data eq '$_') {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last;
                            }
                            elsif ($token_type == LEFT_PAREN) {
                                my $lpnum = 1;
                                for (; $token = $tokens->[$i]; $i++) {
                                    $token_type = $token->{type};

                                    if ($token_type == LEFT_PAREN) {
                                        $lpnum++;
                                    }
                                    elsif ($token_type == RIGHT_PAREN) {
                                        last if --$lpnum <= 0;
                                    }
                                    elsif ($token_type == SPECIFIC_VALUE && $token->{data} eq '$_') {
                                        push @violations, {
                                            filename => $file,
                                            line     => $token->{line},
                                            description => DESC,
                                            explanation => EXPL,
                                            policy => __PACKAGE__,
                                        };
                                        last;
                                    }
                                }
                            }
                        }
                        elsif ($token_data eq 'substr') {
                            $token = $tokens->[++$i] or last;

                            if ($token_type == LEFT_PAREN) {
                                $token = $tokens->[++$i] or last;
                            }

                            if ($token->{type} == SPECIFIC_VALUE && $token->{data} eq '$_') {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
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
        }
    }

    return \@violations;
}

1;

