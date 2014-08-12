package Perl::Lint::Policy::Subroutines::ProhibitNestedSubs;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => 'Nested named subroutine',
    EXPL => 'Declaring a named sub inside another named sub does not prevent the '
            . 'inner sub from being global',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == FUNCTION) {
            my $left_brace_num = 0;
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                if ($token_type == FUNCTION) {
                    if ($left_brace_num > 0) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }
                elsif ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    $left_brace_num--;
                    last if $left_brace_num <= 0;
                }
            }
        }
    }

    return \@violations;
}

1;

