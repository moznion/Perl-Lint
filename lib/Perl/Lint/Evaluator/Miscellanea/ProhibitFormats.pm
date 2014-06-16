package Perl::Lint::Evaluator::Miscellanea::ProhibitFormats;
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
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $next_token;
    for (my $i = 0; my $token = $next_token || $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        my $token_type = $token->{type};
        if ($token_type == FORMAT_DECL && $next_token->{type} != ARROW) {
                                       #  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                       #  XXX workaround for Compiler::Lexer
                                       #  ref: https://github.com/goccy/p5-Compiler-Lexer/issues/33
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
            };
        }
    }

    return \@violations;
}

1;

