package Perl::Lint::Policy::RegularExpressions::ProhibitCaptureWithoutTest;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Capture variable used outside conditional',
    EXPL => [253],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
            # skip reg quotes (because it is recognized as regexp)
            $i += 2;
            next;
        }

        if ($token_type == REG_EXP) {
            next;
        }

        # push @violations, {
        #     filename => $file,
        #     line     => $token->{line},
        #     description => DESC,
        #     explanation => EXPL,
        #     policy => __PACKAGE__,
        # };
    }

    return \@violations;
}

1;

