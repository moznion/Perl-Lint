package Perl::Lint::Policy::RegularExpressions::ProhibitUnusedCapture;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

my %ignore_reg_op = (
    &REG_LIST         => 1,
    &REG_EXEC         => 1,
    &REG_QUOTE        => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove

    my @violations;
    my @captured_for_each_scope = ({});
    my $just_before_regex_token;
    my $assign_ctx = 'NONE';
    my $reg_not_ctx = 0;

    my %depth_for_each_subs;
    my $lbnum_for_scope = 0;
    my $sub_depth = 0;

    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        # to ignore regexp which is not pattern matching
        # NOTE: Compiler::Lexer handles all of the content of q*{} operator as regexp token
        if ($ignore_reg_op{$token_type}) {
            $i += 2; # skip content
            next;
        }

        if ($token_type == ASSIGN) {
            $token = $tokens->[$i-1] or next;
            $token_type = $token->{type};

            $assign_ctx = 'ANY'; # XXX Any!?

            if (
                $token_type == GLOBAL_VAR ||
                $token_type == LOCAL_VAR ||
                $token_type == VAR
            ) {
                $assign_ctx = 'SUCCESS';
            }
            elsif (
                $token_type == GLOBAL_ARRAY_VAR ||
                $token_type == LOCAL_ARRAY_VAR ||
                $token_type == ARRAY_VAR ||
                $token_type == GLOBAL_HASH_VAR ||
                $token_type == LOCAL_HASH_VAR ||
                $token_type == HASH_VAR
            ) {
                $assign_ctx = 'UNLIMITED';
            }
            elsif ($token_type == RIGHT_PAREN) {
                $assign_ctx = 'LIMITED';

                $token = $tokens->[$i-2] or next;
                $token_type = $token->{type};
                if ($token_type == LEFT_PAREN) {
                    $assign_ctx = 'UNLIMITED';
                }
                elsif ($token_type == DEFAULT) {
                    $token = $tokens->[$i-3] or next;
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $assign_ctx = 'UNLIMITED';
                    }
                }
            }

            $token = $tokens->[$i+1] or next;
            $token_type = $token->{type};
            if ($token_type == LEFT_BRACE || $token_type == LEFT_BRACKET) {
                $assign_ctx = 'UNLIMITED';
            }

            next;
        }

        if ($token_type == SEMI_COLON) {
            $assign_ctx = 'NONE';
            next;
        }

        if ($token_type == REG_NOT) {
            $reg_not_ctx = 1;
            next;
        }

        if ($token_type == REG_DOUBLE_QUOTE) {
            $i += 2; # jump to string
            $token = $tokens->[$i];
            $token_type = STRING; # XXX Violence!!
            # fall through
        }
        if ($token_type == STRING) {
            # TODO interpolation
            next;
        }

        if ($token_type == REG_REPLACE_TO) {
            my $escaped = 0;
            my $is_var = 0;
            my @re_chars = split //, $token_data;
            for (my $j = 0; my $re_char = $re_chars[$j]; $j++) {
                if ($escaped) {
                    if ($re_char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
                    }
                    $escaped = 0;
                    next;
                }

                if ($is_var) {
                    if ($re_char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
                    }
                    $is_var = 0;
                    next;
                }

                if ($re_char eq '\\') {
                    $escaped = 1;
                    next;
                }

                if ($re_char eq q<$>) {
                    $is_var = 1;
                    next;
                }
            }

            next;
        }

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if (%{$captured_for_each_scope[$sub_depth]}) {
                push @violations, {
                    filename => $file,
                    line     => $just_before_regex_token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            $captured_for_each_scope[$sub_depth] = {};
            $just_before_regex_token = $token;

            my @re_chars = split //, $token_data;

            my $escaped = 0;
            my $lbnum = 0;
            my $captured_num = 0;
            for (my $j = 0; my $re_char = $re_chars[$j]; $j++) {
                if ($escaped) {
                    if ($re_char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
                    }
                    $escaped = 0;
                    next;
                }

                if ($re_char eq '\\') {
                    $escaped = 1;
                    next;
                }

                if ($re_char eq '[') {
                    $lbnum++;
                    next;
                }

                if ($lbnum > 0) { # in [...]
                    if ($re_char eq ']') {
                        $lbnum--;
                        next;
                    }

                    next;
                }

                if ($re_char eq '(') {
                    my $captured_name = '';
                    if ($re_chars[$j+1] eq '?' && $re_chars[$j+2] eq '<') {
                        for ($j += 3; $re_char = $re_chars[$j]; $j++) {
                            if ($re_char eq '>') {
                                last;
                            }
                            $captured_name .= $re_char;
                        }

                        $captured_for_each_scope[$sub_depth]->{$captured_name} = 1;
                    }
                    elsif ($re_chars[$j+1] ne '?' || $re_chars[$j+2] ne ':') {
                        if ($reg_not_ctx) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                        else {
                            $captured_num++;
                            $captured_for_each_scope[$sub_depth]->{q<$> . $captured_num} = 1;
                        }
                    }
                }
            }

            if ($assign_ctx ne 'NONE') {
                $captured_for_each_scope[$sub_depth] = {};
                my $maybe_reg_opt = $tokens->[$i+2] or next;
                if ($maybe_reg_opt->{type} == REG_OPT) {
                    if ($assign_ctx ne 'UNLIMITED' && $maybe_reg_opt->{data} =~ /g/) {
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

            $reg_not_ctx = 0;
            next;
        }

        # if (
        #     $token_type == BUILTIN_FUNC ||
        #     $token_type == METHOD
        #     # $token_type == KEY
        # ) {
        #     $token = $tokens->[++$i] or last;
        #     $token_type = $token->{type};
        #     if ($token_type == LEFT_PAREN) {
        #         my $lpnum = 1;
        #         for ($i++; $token = $tokens->[$i]; $i++) {
        #             $token_type = $token->{type};
        #             if ($token_type == LEFT_PAREN) {
        #                 $lpnum++;
        #             }
        #             elsif ($token_type == RIGHT_PAREN) {
        #                 last if --$lpnum <= 0;
        #             }
        #         }
        #     }
        # }

        if ($token_type == SPECIFIC_VALUE) {
            if ($token_data =~ /\A\$[0-9]+\Z/) {
                delete $captured_for_each_scope[$sub_depth]->{$token_data};
                next;
            }

            if ($token_data eq '$+') {
                $token = $tokens->[$i+2] or next;
                delete $captured_for_each_scope[$sub_depth]->{$token->{data}};
            }

            next;
        }

        if ($token_type == FUNCTION_DECL) {
            $depth_for_each_subs{$lbnum_for_scope} = 1;
            $assign_ctx = 'NONE'; # XXX Umm...
            $sub_depth++;
            $captured_for_each_scope[$sub_depth] = {};
            next;
        }

        if ($token_type == LEFT_BRACE) {
            $lbnum_for_scope++;
            next;
        }

        if ($token_type == RIGHT_BRACE) {
            $lbnum_for_scope--;
            if (delete $depth_for_each_subs{$lbnum_for_scope}) {
                if (%{pop @captured_for_each_scope}) {
                    push @violations, {
                        filename => $file,
                        line     => $just_before_regex_token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            next;
        }
    }

    if (%{$captured_for_each_scope[-1]}) {
        push @violations, {
            filename => $file,
            line     => $just_before_regex_token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

