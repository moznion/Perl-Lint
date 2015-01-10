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

my $plus_id = Regexp::Lexer::TokenType::Plus->{id};
my $asterisk_id = Regexp::Lexer::TokenType::Asterisk->{id};

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

            my $regexp_tokens = tokenize(qr/$token->{data}/)->{tokens};
            if (grep {($_->{type}->{id} == $asterisk_id) || ($_->{type}->{id} == $plus_id)} @$regexp_tokens) {
                next;
            }

            my $first_token_type_id = $regexp_tokens->[0]->{type}->{id};
            my $last_token_type_id = $regexp_tokens->[-1]->{type}->{id};
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

