package Perl::Lint::Policy::ControlStructures::ProhibitCStyleForLoops;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'C-style "for" loop used',
    EXPL => [100],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == FOR_STATEMENT || $token_type == FOREACH_STATEMENT) {
            my $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                my $semi_colon_count = 0;
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$left_paren_num <= 0;
                    }
                    elsif ($token_type == SEMI_COLON) {
                        $semi_colon_count++;
                    }
                }

                if ($semi_colon_count == 2) {
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
    }

    return \@violations;
}

1;

