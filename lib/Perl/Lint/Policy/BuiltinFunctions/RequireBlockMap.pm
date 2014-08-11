package Perl::Lint::Policy::BuiltinFunctions::RequireBlockMap;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Expression form of "map"',
    EXPL => [169],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'map') {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                next;
            }
            elsif ($token_type != LEFT_BRACE) {
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

