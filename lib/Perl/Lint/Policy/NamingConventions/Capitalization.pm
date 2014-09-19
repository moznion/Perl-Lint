package Perl::Lint::Policy::NamingConventions::Capitalization;
use strict;
use warnings;
use B::Keywords;
use String::CamelCase qw/wordsplit/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '%s', # TODO msg!
    EXPL => [45, 46],
};

my %local_var_declare_token_types = (
    &VAR_DECL   => 1,
    &STATE_DECL => 1,
);

my %global_var_declare_token_types = (
    &OUR_DECL   => 1,
    &LOCAL_DECL => 1,
);

my %var_declare_token_types = (
    %local_var_declare_token_types,
    %global_var_declare_token_types,
);

my %var_token_types = (
    &VAR              => 1,
    &CODE_VAR         => 1,
    &ARRAY_VAR        => 1,
    &HASH_VAR         => 1,
    &GLOBAL_VAR       => 1,
    &GLOBAL_ARRAY_VAR => 1,
    &GLOBAL_HASH_VAR  => 1,
    &LOCAL_VAR        => 1,
    &LOCAL_ARRAY_VAR  => 1,
    &LOCAL_HASH_VAR   => 1,
);

my %globals = map {$_ => 1} ( # TODO integrate?
    @B::Keywords::Arrays,
    @B::Keywords::Hashes,
    @B::Keywords::Scalars,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $packages_rule = '';
    my $package_exemptions = '';

    my $subroutines_rule = '';
    my $subroutine_exemptions = '';

    my $local_lexical_variables_rule = '';
    my $local_lexical_variable_exemptions = '';

    my $global_variables_rule = '';
    my $global_variable_exemptions = '';

    my $labels_rule = '';
    my $label_exemptions = '';

    if (my $this_policies_rule = $args->{capitalization}) {
        $packages_rule = $this_policies_rule->{packages} || '';
        $package_exemptions = $this_policies_rule->{package_exemptions} || '';

        $subroutines_rule = $this_policies_rule->{subroutines} || '';
        $subroutine_exemptions = $this_policies_rule->{subroutine_exemptions} || '';

        $local_lexical_variables_rule = $this_policies_rule->{local_lexical_variables} || '';
        $local_lexical_variable_exemptions = $this_policies_rule->{local_lexical_variable_exemptions} || '';

        $global_variables_rule = $this_policies_rule->{global_variables} || '';
        $global_variable_exemptions = $this_policies_rule->{global_variable_exemptions} || '';

        $labels_rule = $this_policies_rule->{labels} || '';
        $label_exemptions = $this_policies_rule->{label_exemptions} || '';
    }

    my @violations;

    TOP: for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        # for variables name
        if ($var_declare_token_types{$token_type}) {
            my $condition;
            my $exemptions;
            my $is_global_var = 0;
            if ($local_var_declare_token_types{$token_type}) {
                $condition  = $class->_choose_condition_dispenser($local_lexical_variables_rule) || \&_is_singlecase;
                $exemptions = $local_lexical_variable_exemptions;
            }
            else {
                $condition  = $class->_choose_condition_dispenser($global_variables_rule) || \&_is_singlecase;
                $exemptions = $global_variable_exemptions;
                $is_global_var = 1;
            }

            $token = $tokens->[++$i] or last;
            $token_type = $token->{type};

            # when multiple variables declared
            if ($token_type == LEFT_PAREN) {
                my $lpnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0 ;
                    }
                    elsif ($var_token_types{$token_type}) {
                        # To ignore variables from other packages
                        # TODO
                        my $next_token = $tokens->[$i+1] || {};
                        if ($next_token->{type} && $next_token->{type} == NAMESPACE_RESOLVER) {
                            next;
                        }

                        $token_data = $token->{data};

                        if ($is_global_var && $globals{$token_data}) {
                            next;
                        }

                        $token_data = substr($token_data, 1); # to exclude sigils

                        if ($token_data =~ /\A$exemptions\Z/) {
                            next;
                        }

                        if (ref $condition ne 'CODE') {
                            if ($token_data =~ /\A$condition\Z/) {
                                next;
                            }

                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => sprintf(DESC, $token_data), # TODO
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            next;
                        }

                        for my $part (wordsplit($token_data)) {
                            if (!$condition->($part)) { # include Upper Case
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => sprintf(DESC, $token_data), # TODO
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last;
                            }
                        }
                    }
                }

                next;
            }

            # To ignore variables from other packages
            # TODO
            my $next_token = $tokens->[$i+1] || {};
            if ($next_token->{type} && $next_token->{type} == NAMESPACE_RESOLVER) {
                next;
            }

            $token_data = $token->{data};

            if ($is_global_var && $globals{$token_data}) {
                next;
            }

            $token_data = substr($token_data, 1); # to exclude sigils

            if ($token_data =~ /\A$exemptions\Z/) {
                next;
            }

            if (ref $condition ne 'CODE') {
                if ($token_data =~ /\A$condition\Z/) {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data), # TODO
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }

            for my $part (wordsplit($token_data)) {
                if (!$condition->($part)) { # include Upper Case
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => sprintf(DESC, $token_data), # TODO
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    last;
                }
            }
            next;
        }

        # for subroutines name
        if ($token_type == FUNCTION_DECL) {
            $token = $tokens->[++$i] or last;
            $token_type = $token->{type};

            if ($token_type == NAMESPACE) {
                my $last_namespace_token;

                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == NAMESPACE) {
                        $last_namespace_token = $token;
                    }
                    elsif ($token_type != NAMESPACE_RESOLVER) {
                        last;
                    }
                }

                $token = $last_namespace_token;
            }
            elsif ($token_type != FUNCTION) {
                next;
            }

            my $condition = $class->_choose_condition_dispenser($subroutines_rule) || \&_is_started_with_lower;

            $token_data = $token->{data};

            if ($token_data =~ /\A$subroutine_exemptions\Z/) {
                next;
            }

            if (ref $condition ne 'CODE') {
                if ($token_data =~ /\A$condition\Z/) {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data), # TODO
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }

            for my $part (wordsplit($token_data)) { # to exclude sigils
                if (!$condition->($part)) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => sprintf(DESC, $token_data), # TODO
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    last;
                }
            }

            next;
        }

        # for package's name
        if ($token_type == PACKAGE) {
            $token = $tokens->[++$i] or last;
            $token_type = $token->{type};
            $token_data = $token->{data};

            # special case: main
            if ($token_type == CLASS && $token_data eq 'main') {
                next;
            }

            if ($package_exemptions && $token_data =~ /\A$package_exemptions\Z/) {
                next;
            }

            my $condition = $class->_choose_condition_dispenser($packages_rule) || \&_is_started_with_upper;

            my $package_full_name = $token_data;
            if (ref $condition eq 'CODE') {
                for my $part (wordsplit($token_data)) {
                    if (!$condition->($part)) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => sprintf(DESC, $token_data), # TODO
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };

                        next TOP;
                    }
                }
            }
            elsif ($token_type == CLASS) {
                if ($package_full_name =~ /\A$condition\Z/) {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data), # TODO
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }

            if ($token_type == NAMESPACE) {
                if (ref $condition ne 'CODE') {
                    for ($i++; $token = $tokens->[$i]; $i++) { # TODO
                        $token_type = $token->{type};
                        $token_data = $token->{data};
                        if ($token_type == NAMESPACE || $token_type == NAMESPACE_RESOLVER) {
                            $package_full_name .= $token_data;
                        }
                        else {
                            last;
                        }
                    }
                    if ($package_full_name =~ /\A$condition\Z/) {
                        next;
                    }

                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => sprintf(DESC, $token_data), # TODO
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    next;
                }

                SCAN_NAMESPACE: for ($i++; $token = $tokens->[$i]; $i++) { # TODO
                    $token_type = $token->{type};
                    $token_data = $token->{data};
                    if ($token_type == NAMESPACE) {
                        for my $part (wordsplit($token_data)) {
                            if (!$condition->($part)) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => sprintf(DESC, $token_data), # TODO
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last SCAN_NAMESPACE;
                            }
                        }
                    }
                    elsif ($token_type != NAMESPACE_RESOLVER) {
                        last;
                    }
                }
            }

            next;
        }

        # for constant variables
        #   * Readonly::Scalar
        #   * const (From Const::Fast)
        {
            my $is_const_decl = 0;
            if ($token_type == NAMESPACE && $token_data eq 'Readonly') {
                $i += 2;
                $token = $tokens->[$i] or last;
                if ($token->{type} == NAMESPACE && $token->{data} eq 'Scalar') {
                    $is_const_decl = 1;
                }
            }
            elsif ($token_type == KEY && $token_data eq 'const') {
                $is_const_decl = 1;
            }

            if ($is_const_decl) {
                $token = $tokens->[++$i] or last;
                if (!$var_token_types{$token->{type}}) {
                    $token = $tokens->[++$i] or last;
                }

                if ($var_token_types{$token->{type}}) {
                    $token_data = $token->{data};
                    if (uc $token_data ne $token_data) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => sprintf(DESC, $token_data), # TODO
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }

                next;
            }
        }

        # for constants
        #   * use constant
        if ($token_type == USE_DECL) {
            $token = $tokens->[++$i] or last;
            if ($token->{type} != USED_NAME || $token->{data} ne 'constant') {
                next;
            }

            for ($i++; $token = $tokens->[$i]; $i++) {
                if ($token->{type} != ARROW) {
                    next;
                }

                my $key = $tokens->[$i-1]->{data};
                if (uc $key ne $key) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => sprintf(DESC, $key), # TODO
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }

            next;
        }

        # for LABELs
        if ($token_type == KEY) {
            my $next_token = $tokens->[$i+1] or last;
            if ($next_token->{type} != COLON) {
                next;
            }

            if ($token_data =~ /\A$label_exemptions\Z/) {
                next;
            }

            my $condition = $class->_choose_condition_dispenser($labels_rule) || \&_is_all_upper;

            if (ref $condition ne 'CODE') {
                if ($token_data =~ /\A$condition\Z/) {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data), # TODO
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }

            if (!$condition->($token_data)) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data), # TODO
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            next;
        }

    }

    return \@violations;
}

sub _choose_condition_dispenser {
    my ($self, $rule) = @_;

    if ($rule eq ':single_case') {
        return \&_is_singlecase;
    }
    elsif ($rule eq ':all_lower') {
        return \&_is_all_lower;
    }
    elsif ($rule eq ':all_upper') {
        return \&_is_all_upper;
    }
    elsif ($rule eq ':starts_with_lower') {
        return \&_is_started_with_lower;
    }
    elsif ($rule eq ':starts_with_upper') {
        return \&_is_started_with_upper;
    }
    elsif ($rule eq ':no_restriction') {
        return \&_everything_will_be_alright;
    }
    elsif ($rule) {
        return $rule; # XXX
    }

    return;
}

sub _is_all_lower {
    my ($part) = @_;
    return lc($part) eq $part;
}

sub _is_all_upper {
    my ($part) = @_;
    return uc($part) eq $part;
}

sub _is_singlecase {
    my ($part) = @_;
    return uc($part) eq $part || lc($part) eq $part;
}

sub _is_started_with_lower {
    my ($part) = @_;
    return lcfirst($part) eq $part;
}

sub _is_started_with_upper {
    my ($part) = @_;
    return ucfirst($part) eq $part;
}

sub _everything_will_be_alright {
    return 1;
}

1;

