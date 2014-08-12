package Perl::Lint::Policy::ValuesAndExpressions::RequireUpperCaseHeredocTerminator;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Heredoc terminator must be quoted',
    EXPL => [64],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        # XXX workaround
        # Compiler::Lexer cannot recognize heredoc tag as bare word and lowercase
        # https://github.com/goccy/p5-Compiler-Lexer/issues/37
        #
        # e.g.
        #   <<endquote
        my $is_before_left_shift = 0;
        if ($token_type == LEFT_SHIFT) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            $is_before_left_shift = 1;
        }

        if (
            $token_type == HERE_DOCUMENT_TAG ||
            $token_type == HERE_DOCUMENT_RAW_TAG ||
            ($is_before_left_shift && $token_type == KEY)
        ) {
            if ($token->{data} =~ /[a-z]/) {
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

