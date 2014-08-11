package Perl::Lint::Policy::InputOutput::ProhibitBarewordFileHandles;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Bareword file handle opened',
    EXPL => [202, 204],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'open') {
            $token = $tokens->[++$i];
            $token_type = $token->{type};

            if ($token_type == LEFT_PAREN) {
                $token = $tokens->[++$i];
                $token_type = $token->{type};
            }

            if ($token_type == KEY) {
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

