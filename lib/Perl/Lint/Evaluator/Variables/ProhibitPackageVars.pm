package Perl::Lint::Evaluator::Variables::ProhibitPackageVars;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == OUR_DECL) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $violation;
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
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
                        if ($token->{data} !~ /\A\$[A-Z_]+\Z/) {
                            $violation ||= +{
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
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
                if ($token->{data} !~ /\A\$[A-Z_]+\Z/) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
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
            $token = $tokens->[++$i];
            if ($token->{type} == NAMESPACE_RESOLVER) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                };
            }
        }
        elsif ($token_type == SPECIFIC_VALUE && $token_data eq '$:') {
            $token = $tokens->[++$i];
            if ($token->{type} == COLON) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
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
                        if ($elem =~ /\A[\$\@\%]/) {
                            $is_used_package_var = 1;
                        }
                    }
                }
                if ($token_type == STRING || $token_type == RAW_STRING) {
                    if ($token_data =~ /\A[\$\@\%]/) {
                        $is_used_package_var = 1;
                    }
                }

                if ($token_type == SEMI_COLON) {
                    last;
                }
            }
            if ($is_used_package_var) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                };
            }
        }
    }

    return \@violations;
}

1;

