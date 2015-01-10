package Perl::Lint::Policy::RegularExpressions::ProhibitFixedStringMatches;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Regexp::Lexer qw(tokenize);
use Regexp::Lexer::TokenType;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use "eq" or hash instead of fixed-pattern regexps',
    EXPL => [271, 272],
};

# to use sanitize
my $alternation_id = Regexp::Lexer::TokenType::Alternation->{id};
my $lparen_id = Regexp::Lexer::TokenType::LeftParenthesis->{id};
my $rparen_id = Regexp::Lexer::TokenType::RightParenthesis->{id};
my $question_id = Regexp::Lexer::TokenType::Question->{id};
my $colon_id = Regexp::Lexer::TokenType::Colon->{id};

# to use check fixed string
my $character_id = Regexp::Lexer::TokenType::Character->{id};
my $escaped_character_id = Regexp::Lexer::TokenType::EscapedCharacter->{id};

# anchors
my $beginning_of_line_id = Regexp::Lexer::TokenType::BeginningOfLine->{id};
my $end_of_line_id = Regexp::Lexer::TokenType::EndOfLine->{id};
my $escaped_beginning_of_line_id = Regexp::Lexer::TokenType::EscapedBeginningOfString->{id};
my $escaped_end_of_line_id = Regexp::Lexer::TokenType::EscapedEndOfString->{id};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    my $is_reg_quoted = 0;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if ($is_reg_quoted) {
                $is_reg_quoted = 0;
                next;
            }

            my $maybe_regopt;
            if ($token_type == REG_EXP) {
                $maybe_regopt = $tokens->[$i+2];
            }
            else {
                $maybe_regopt = $tokens->[$i+4];
                if ($maybe_regopt->{type} == REG_DELIM) { # if it use brackets as delimiter
                    $maybe_regopt = $tokens->[$i+5];
                }
            }

            my $is_with_m_opt = 0;
            if ($maybe_regopt) {
                if ($maybe_regopt->{type} == REG_OPT && $maybe_regopt->{data} =~ /m/) {
                    $is_with_m_opt = 1;
                }
            }

            my @regexp_tokens = eval {
                @{tokenize(qr/$token->{data}/)->{tokens}};
            };

            if ($@) {
                # XXX First aid!
                # Maybe regexp is produced by `tr///` or `y///` operator if it reaches here.
                next;
            }

            if (scalar @regexp_tokens < 2) {
                next;
            }

            my $first_token_type_id = (shift @regexp_tokens)->{type}->{id};
            my $last_token_type_id = (pop @regexp_tokens)->{type}->{id};

            if (defined $first_token_type_id && defined $last_token_type_id) {
                if ($is_with_m_opt) {
                    if ($first_token_type_id == $beginning_of_line_id || $last_token_type_id == $end_of_line_id) {
                        next;
                    }
                }

                if (
                    ($first_token_type_id == $beginning_of_line_id || $first_token_type_id == $escaped_beginning_of_line_id) &&
                    ($last_token_type_id == $end_of_line_id || $last_token_type_id == $escaped_end_of_line_id)
                ) {
                    my @not_character_tokens = ();

                    for (my $j = 0, my $type_id; my $regexp_token = $regexp_tokens[$j]; $j++) {
                        $type_id = $regexp_token->{type}->{id};
                        if (
                            $type_id == $alternation_id ||
                            $type_id == $rparen_id
                        ) {
                            next;
                        }

                        if ($type_id == $lparen_id) {
                            my $next_regexp_token = $regexp_tokens[$j+1];
                            if (defined $next_regexp_token && $next_regexp_token->{type}->{id} == $question_id) {
                                $next_regexp_token = $regexp_tokens[$j+2];
                                if (defined $next_regexp_token && $next_regexp_token->{type}->{id} == $colon_id) {
                                    $j += 2;
                                    next;
                                }
                            }

                            next;
                        }

                        if ($type_id != $character_id && $type_id != $escaped_character_id) {
                            push @not_character_tokens, $regexp_token;
                            next;
                        }
                    }

                    if (@not_character_tokens) {
                        next;
                    }

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
        elsif ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
            $is_reg_quoted = 1;
        }
    }

    return \@violations;
}

1;

