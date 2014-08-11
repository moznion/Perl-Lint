package Perl::Lint::Policy::Miscellanea::ProhibitFormats;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Format used',
    EXPL => [449],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0, my $next_token; my $token = $tokens->[$i]; $i++) {
        if ($token->{type} == FORMAT_DECL) {
            $next_token = $tokens->[$i+1];
            if ($next_token->{type} != ARROW) {
                #  XXX workaround for Compiler::Lexer
                #  ref: https://github.com/goccy/p5-Compiler-Lexer/issues/33
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

