package Perl::Lint::Policy::Variables::ProhibitPunctuationVars;
use strict;
use warnings;
use Compiler::Lexer;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => 'Magic punctuation variable %s used',
    EXPL => [79],
};

my %var_token_types = (
    &VAR       => 1,
    &ARRAY_VAR => 1,
    &HASH_VAR  => 1,

    &GLOBAL_VAR       => 1,
    &GLOBAL_ARRAY_VAR => 1,
    &GLOBAL_HASH_VAR  => 1,
);

my %expands_regexp_token_types = (
    &REG_EXEC => 1,
    &REG_DECL => 1,
    &REG_DOUBLE_QUOTE => 1,
);

my %special_variable_token_types = (
    &SPECIFIC_VALUE => 1,
    &ARRAY_SIZE     => 1,
);

my %magic_variables = (
    '$1' => 1, '$2' => 1, '$3' => 1,
    '$4' => 1, '$5' => 1, '$6' => 1,
    '$7' => 1, '$8' => 1, '$9' => 1,
    '$_' => 1, '$&' => 1, '$`' => 1,
    '$+' => 1, '@+' => 1, '@*' => 1,
    '%+' => 1, '$*' => 1, '$.' => 1,
    '$/' => 1, '$|' => 1, '$(' => 1,
    '$"' => 1, '$;' => 1, '$%' => 1,
    '$=' => 1, '$-' => 1, '@-' => 1,
    '%-' => 1, '$)' => 1, '$~' => 1,
    '$^' => 1, '$:' => 1, '$?' => 1,
    '$!' => 1, '%!' => 1, '$@' => 1,
    '$$' => 1, '$<' => 1, '$>' => 1,
    '$0' => 1, '$[' => 1, '$]' => 1,
    '@_' => 1,

    q{$'} => 1,

    '$^L' => 1, '$^A' => 1, '$^E' => 1,
    '$^C' => 1, '$^D' => 1, '$^F' => 1,
    '$^H' => 1, '$^I' => 1, '$^M' => 1,
    '$^N' => 1, '$^O' => 1, '$^P' => 1,
    '$^R' => 1, '$^S' => 1, '$^T' => 1,
    '$^V' => 1, '$^W' => 1, '$^X' => 1,
    '%^H' => 1,

    '$\\'  => 1,
    '$::|' => 1,
    '$}'   => 1,
    '$,'   => 1,
    '$#'   => 1,
    '$#+'  => 1,
    '$#-'  => 1,
);

my %ignore_for_interpolation = (
    q{$'} => 1,
    q{$$} => 1,
    q{$#} => 1,
    q{$:} => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $string_mode = $args->{prohibit_punctuation_vars}->{string_mode} || '';

    my %exempt_vars = $string_mode eq 'thorough' ? () : (
        '$_' => 1, '@_' => 1, '$]' => 1,
        '$1' => 1, '$2' => 1, '$3' => 1,
        '$4' => 1, '$5' => 1, '$6' => 1,
        '$7' => 1, '$8' => 1, '$9' => 1,
    );

    for my $exempt_var (split(/\s+/, $args->{prohibit_punctuation_vars}->{allow} || '')) {
        $exempt_vars{$exempt_var} = 1;
    }

    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    my $lexer_for_str = Compiler::Lexer->new;

    my @violations;
    for (
        my $i = 0, my $token_type, my $token_data, my $is_ref = 0, my $is_raw_heredoc_tag = 0;
        my $token = $tokens->[$i];
        $i++
    ) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($special_variable_token_types{$token_type}) {
            if ($is_ref) {
                $is_ref = 0;
                next;
            }

            if ($exempt_vars{$token_data}) {
                next;
            }

            if (! $magic_variables{$token_data}) {
                next;
            }

            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => sprintf(DESC, $token_data),
                explanation => EXPL,
                policy => __PACKAGE__,
            };
            next;
        }

        if ($var_token_types{$token_type}) {
            if ($is_ref) {
                $is_ref = 0;
                next;
            }

            if ($exempt_vars{$token_data}) {
                next;
            }

            if (! $magic_variables{$token_data}) {
                next;
            }

            if (substr($token_data, 1, 1) =~ /\A[^a-zA-Z]\Z/) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data),
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
            next;
        }

        if ($token_type == REF) {
            $is_ref = 1;
            next;
        }

        if ($token_type == HERE_DOCUMENT_RAW_TAG) {
            $is_raw_heredoc_tag = 1;
            next;
        }

        if ($token_type == HERE_DOCUMENT_END) {
            $is_raw_heredoc_tag = 0;
            next;
        }

        if ($expands_regexp_token_types{$token_type}) {
            $i += 2;
            $token = $tokens->[$i];
            if ($token->{type} != REG_EXP) { # when content is empty
                next;
            }
            $token_data = $token->data;
            $token_type = STRING;
        } # fall through

        if (
            $token_type == STRING ||
            $token_type == EXEC_STRING
            # ($token_type == HERE_DOCUMENT && $is_raw_heredoc_tag)
        ) {
            if ($string_mode eq 'disable') {
                next;
            }

            my $parts = $lexer_for_str->tokenize($token_data);
            my $ref_count = 0;
            for (my $j = 0, my $part_type, my $used_var; my $part = $parts->[$j]; $j++) {
                $part_type = $part->{type};
                $used_var  = $part->{data};

                if ($part_type == REF) {
                    $ref_count++;
                    next;
                }

                if ($ref_count % 2 != 0) {
                    $ref_count = 0;
                    next;
                }

                if ($part_type == SPECIFIC_VALUE) {
                    if ($used_var eq '$:') {
                        $part = $parts->[$j+1];

                        if ($part && $part->{type} == COLON) {
                            $part = $parts->[$j+2];
                            if ($part && $part->{type} == BIT_OR) {
                                $used_var = '$::|';
                            }
                            else {
                                next;
                            }
                        }
                    }
                    # TODO
                    # elsif ($used_var eq q{$'}) {
                    #     $part = $parts->[$j+1];
                    #     if ($part && $part->{type} == KEY) {
                    #         # next;
                    #     }
                    # }
                }
                elsif ($part_type != ARRAY_SIZE) {
                    if (!$var_token_types{$part_type}) {
                        next;
                    }

                    $part = $parts->[++$j];
                    if ($part) {
                        if ($used_var eq '$') {
                            if ($part->{type} == RIGHT_BRACE) {
                                $used_var = '$}';
                            }
                        }
                        elsif ($used_var eq '@') {
                            if ($part->{type} == MUL) {
                                $used_var = '@*';
                            }
                        }
                        elsif ($used_var eq '%-') {
                            if ($part->{type} == INT) { # for formatting. e.g. "%-04f"
                                next;
                            }
                        }
                    }
                }

                if ($exempt_vars{$used_var}) {
                    next;
                }

                if ($string_mode eq 'simple' && $ignore_for_interpolation{$used_var}) {
                    next;
                }

                if ($magic_variables{$used_var}) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => sprintf(DESC, $used_var),
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }

            next;
        }
    }

    return \@violations;
}

1;

