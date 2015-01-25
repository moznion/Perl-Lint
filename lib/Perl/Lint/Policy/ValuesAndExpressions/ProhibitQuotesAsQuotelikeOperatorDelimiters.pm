package Perl::Lint::Policy::ValuesAndExpressions::ProhibitQuotesAsQuotelikeOperatorDelimiters;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    EXPL => 'Using quotes as delimiters for quote-like operators obfuscates code',
};

my %TARGET_REGS = (
    &REG_QUOTE        => 1,
    &REG_DOUBLE_QUOTE => 1,
    &REG_LIST         => 1,
    &REG_EXEC         => 1,
    &REG_DECL         => 1,
    &REG_MATCH        => 1,

    &REG_ALL_REPLACE  => 1,
);

# TODO operator which has `replace from` and `replace to` doesn't work certainly.
# It maybe caused by Compiler::Lexer's bug.

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my %target_regs_allows_single_quote = (
        'qx' => 1,
        'qr' => 1,
        'm'  => 1,
    );
    if (defined (my $single_quote_allowed_operators = $args->{single_quote_allowed_operators})) {
        %target_regs_allows_single_quote = ();
        for my $allow_delim (split qr/\s+/, $single_quote_allowed_operators) {
            $target_regs_allows_single_quote{$allow_delim} = 1;
        }
    }

    my %target_regs_allows_double_quote = ();
    if (defined (my $double_quote_allowed_operators = $args->{double_quote_allowed_operators})) {
        for my $allow_delim (split qr/\s+/, $double_quote_allowed_operators) {
            $target_regs_allows_double_quote{$allow_delim} = 1;
        }
    }

    my %target_regs_allows_back_quote = ();
    if (defined (my $back_quote_allowed_operators = $args->{back_quote_allowed_operators})) {
        for my $allow_delim (split qr/\s+/, $back_quote_allowed_operators) {
            $target_regs_allows_back_quote{$allow_delim} = 1;
        }
    }

    my @violations;
    my $next_token;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($TARGET_REGS{$token_type}) {
            $next_token = $tokens->[++$i];
            if ($next_token && $next_token->{type} == REG_DELIM) {
                my $next_token_data= $next_token->{data};

                my $desc = '';
                if ($next_token_data eq q<'> && !$target_regs_allows_single_quote{$token_data}) {
                    $desc= 'Single-quote used as quote-like operator delimiter';
                }
                elsif ($next_token_data eq q<"> && !$target_regs_allows_double_quote{$token_data}) {
                    $desc = 'Double-quote used as quote-like operator delimiter';
                }
                elsif ($next_token_data eq q<`> && !$target_regs_allows_back_quote{$token_data}) {
                    $desc = 'Back-quote (back-tick) used as quote-like operator delimiter';
                }
                else {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $next_token->{line},
                    description => $desc,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

