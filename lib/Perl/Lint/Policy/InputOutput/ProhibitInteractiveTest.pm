package Perl::Lint::Policy::InputOutput::ProhibitInteractiveTest;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use IO::Interactive::is_interactive() instead of -t',
    EXPL => [218],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};
        if ($token_type == HANDLE && $token_data eq '-t') {
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

1;

