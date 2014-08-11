package Perl::Lint::Policy::ControlStructures::ProhibitUnlessBlocks;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"unless" block used',
    EXPL => [97],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == UNLESS_STATEMENT) {
            if ($tokens->[++$i]->{type} == LEFT_PAREN) {
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$left_paren_num <= 0;
                    }
                }
                if ($tokens->[++$i]->{type} == LEFT_BRACE) {
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

