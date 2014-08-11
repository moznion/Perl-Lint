package Perl::Lint::Policy::BuiltinFunctions::RequireGlobFunction;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Glob written as <...>',
    EXPL => [167],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == HANDLE_DELIM) {
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};

                if ($token_type == MUL) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
                elsif ($token_type == GREATER) {
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

