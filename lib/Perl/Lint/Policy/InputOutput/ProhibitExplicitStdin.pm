package Perl::Lint::Policy::InputOutput::ProhibitExplicitStdin;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use "<>" or "<ARGV>" or a prompting module instead of "<STDIN>"',
    EXPL => [216, 220, 221],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    my $is_in_context_of_close = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == TYPE_STDIN) {
            next if $is_in_context_of_close;
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
        elsif ($token_type == BUILTIN_FUNC && $token_data eq 'close') {
            $is_in_context_of_close = 1;
        }
        elsif ($token_type == SEMI_COLON) {
            $is_in_context_of_close = 0;
        }
    }

    return \@violations;
}

1;

