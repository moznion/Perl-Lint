package Perl::Lint::Policy::CodeLayout::ProhibitQuotedWordLists;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO TODO TODO integrate duplicated functions between assign context and use context !!!!

use constant {
    DESC => 'List of quoted literal words',
    EXPL => 'Use "qw()" instead',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $min_elements = $args->{prohibit_quoted_word_lists}->{min_elements} || 2;
    my $strict = $args->{prohibit_quoted_word_lists}->{strict} || 0;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if (
            $token_type == ARRAY_VAR       ||
            $token_type == LOCAL_ARRAY_VAR ||
            $token_type == GLOBAL_ARRAY_VAR
        ) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == ASSIGN) {
                $token = $tokens->[++$i];
                $token_type = $token->{type};
                if ($token_type == LEFT_PAREN) {
                    my $left_paren_num = 1;
                    my $is_violated = 1;
                    my $elem_num = 0;

                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }
                        elsif ($token_type == RIGHT_PAREN) {
                            if (--$left_paren_num <= 0) {
                                if ($is_violated && $elem_num >= $min_elements) {
                                    push @violations, {
                                        filename => $file,
                                        line     => $token->{line},
                                        description => DESC,
                                        explanation => EXPL,
                                        policy => __PACKAGE__
                                    };
                                }
                                last;
                            }
                        }
                        elsif ($token_type == STRING || $token_type == RAW_STRING) {
                            $elem_num++;

                            next if $strict;

                            if ($token->{data} !~ /\A[a-zA-Z-]+\Z/) {
                                $is_violated = 0;
                            }
                        }
                        elsif ($token_type != COMMA) {
                            $elem_num++;
                            $is_violated = 0;
                        }
                    }
                }
            }
        }
        elsif ($token_type == USE_DECL) {
            USE_STATEMENT: for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_PAREN) {
                    my $left_paren_num = 1;
                    my $is_violated = 1;
                    my $elem_num = 0;

                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }
                        elsif ($token_type == RIGHT_PAREN) {
                            if (--$left_paren_num <= 0) {
                                if ($is_violated && $elem_num >= $min_elements) {
                                    push @violations, {
                                        filename => $file,
                                        line     => $token->{line},
                                        description => DESC,
                                        explanation => EXPL,
                                        policy => __PACKAGE__,
                                    };
                                }
                                last USE_STATEMENT;
                            }
                        }
                        elsif ($token_type == STRING || $token_type == RAW_STRING) {
                            $elem_num++;

                            next if $strict;

                            if ($token->{data} !~ /\A[a-zA-Z-]+\Z/) {
                                $is_violated = 0;
                            }
                        }
                        elsif ($token_type != COMMA) {
                            $elem_num++;
                            $is_violated = 0;
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

