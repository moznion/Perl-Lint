package Perl::Lint::Policy::ControlStructures::ProhibitCascadingIfElse;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Cascading if-elsif chain',
    EXPL => [117, 118],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_elsif = $args->{prohibit_cascading_if_else}->{max_elsif} || 2;

    my @violations;
    my $is_chained = 0;
    my $cascading_num = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == ELSIF_STATEMENT) {
            $cascading_num++;

            if ($is_chained && $cascading_num > $max_elsif) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            my $left_brace_num = 0;
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                if ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    last if --$left_brace_num <= 0;
                }
            }
            $is_chained = 1;
            next;
        }

        $cascading_num = 0;
        $is_chained = 0;
    }

    return \@violations;
}

1;


