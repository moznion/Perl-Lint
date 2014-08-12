package Perl::Lint::Policy::Variables::ProhibitPackageVars;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Package variable declared or used',
    EXPL => [73, 75],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @allowed_packages = qw/Data::Dumper File::Find FindBin Log::Log4perl/;
    if (my $add_packages = $args->{prohibit_package_vars}->{add_packages}) {
        push @allowed_packages, split /\s+/, $add_packages;
    }

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == OUR_DECL) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $violation;
                my $left_paren_num = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            if ($violation) {
                                push @violations, $violation;
                                undef $violation;
                            }
                            last;
                        }
                    }
                    elsif (
                        $token_type == GLOBAL_VAR ||
                        $token_type == GLOBAL_ARRAY_VAR ||
                        $token_type == GLOBAL_HASH_VAR ||
                        $token_type == VAR ||
                        $token_type == ARRAY_VAR ||
                        $token_type == HASH_VAR
                    ) {
                        if ($token->{data} !~ /\A.[A-Z0-9_]+\Z/) {
                            $violation ||= +{
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
            elsif (
                $token_type == GLOBAL_VAR ||
                $token_type == GLOBAL_ARRAY_VAR ||
                $token_type == GLOBAL_HASH_VAR ||
                $token_type == VAR ||
                $token_type == ARRAY_VAR ||
                $token_type == HASH_VAR
            ) {
                if ($token->{data} !~ /\A.[A-Z0-9_]+\Z/) {
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
        elsif ($token_type == LOCAL_DECL) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $violation;
                my $left_paren_num = 1;
                my $does_exist_namespace_resolver = 0;

                my @namespaces;

                my @packages;
                my @var_names;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        push @var_names, pop @namespaces;
                        push @packages, join '::', @namespaces;
                        if (--$left_paren_num <= 0) {
                            last;
                        }
                        @namespaces = ();
                    }
                    elsif ($token_type == COMMA) {
                        push @var_names, pop @namespaces;
                        push @packages, join '::', @namespaces;
                        @namespaces = ();
                    }
                    elsif ($token_type == NAMESPACE_RESOLVER) {
                        $does_exist_namespace_resolver = 1;
                    }
                    else {
                        push @namespaces, $token->{data};
                    }
                }

                if ($does_exist_namespace_resolver) {
                    $token = $tokens->[++$i];
                    if ($token->{type} == ASSIGN) {
                        my $is_violated = 0;
                        for my $package (@packages) {
                            if (!any {$package =~ /\A[\$\@\%]$_/} @allowed_packages) {
                                $is_violated = 1;
                            }
                        }

                        # TODO check @var_names ?

                        if ($is_violated) {
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
            else {
                my $does_exist_namespace_resolver = 0;
                my $is_assigned = 0;
                my @namespaces = ($token->{data});
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    $token_data = $token->{data};
                    if ($token_type == NAMESPACE) {
                        push @namespaces, $token_data;
                    }
                    elsif ($token_type == NAMESPACE_RESOLVER) {
                        $does_exist_namespace_resolver = 1;
                    }
                    elsif ($token_type == ASSIGN) {
                        $is_assigned = 1;
                        last;
                    }
                    elsif ($token_type == SEMI_COLON) {
                        last;
                    }
                }

                if ($does_exist_namespace_resolver && $is_assigned) {
                    pop @namespaces; # throw variable name away
                    my $package_name = join '::', @namespaces;
                    if (any {$package_name =~ /\A[\$\@\%]$_/} @allowed_packages) {
                        next;
                    }

                    # TODO check the var name
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
        elsif (
            $token_type == GLOBAL_VAR ||
            $token_type == GLOBAL_ARRAY_VAR ||
            $token_type == GLOBAL_HASH_VAR ||
            $token_type == VAR ||
            $token_type == ARRAY_VAR ||
            $token_type == HASH_VAR
        ) {
            my @namespaces = ($token->{data});

            my $does_exist_namespace_resolver = $tokens->[$i+1]->{type} == NAMESPACE_RESOLVER ? 1 : 0;

            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == ASSIGN || $token_type == SEMI_COLON) {
                    last;
                }
                elsif ($token_type == NAMESPACE) {
                    push @namespaces, $token->{data};
                }
            }

            if ($does_exist_namespace_resolver) {
                my $var_name = pop @namespaces;

                my $package_name = join '::', @namespaces;
                if (any {$package_name =~ /\A[\$\@\%]$_/} @allowed_packages) {
                    next;
                }

                if ($var_name !~ /\A.[A-Z0-9_]+\Z/) {
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
        elsif ($token_type == SPECIFIC_VALUE && $token_data eq '$:') {
            $token = $tokens->[++$i];
            my $does_exist_namespace_resolver = $token->{type} == COLON ? 1 : 0;

            my $var_token;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == ASSIGN) {
                    $var_token = $tokens->[$i-1];
                }
                elsif ($token_type == SEMI_COLON) { # XXX skip to the edge
                    last;
                }
            }

            if ($does_exist_namespace_resolver && $var_token->{data} !~ /\A.[A-Z0-9_]+\Z/) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == USED_NAME && $token_data eq 'vars') {
            my $is_used_package_var = 0;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                $token_data = $token->{data};

                if ($token_type == REG_EXP) {
                    for my $elem (split /\s+/, $token_data) {
                        if ($elem =~ /\A[\$\@\%](.*)\Z/) {
                            if ($1 !~ /\A[A-Z0-9_]+\Z/) {
                                $is_used_package_var = 1;
                            }
                        }
                    }
                }
                elsif ($token_type == STRING || $token_type == RAW_STRING) {
                    if ($token_data =~ /\A[\$\@\%](.*)\Z/) {
                        if ($1 !~ /\A[A-Z0-9_]+\Z/) {
                            $is_used_package_var = 1;
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
            if ($is_used_package_var) {
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

