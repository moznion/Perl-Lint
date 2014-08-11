package Perl::Lint::Policy::InputOutput::ProhibitOneArgSelect;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'One-argument "select" used',
    EXPL => [224],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'select') {
            $token = $tokens->[++$i];
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $args_num = 0;
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$left_paren_num <= 0;
                    }
                    else {
                        $args_num++;
                    }
                }
                if ($args_num == 1) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            else {
                my $args_num = 0;
                for (; my $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        last;
                    }
                    else {
                        $args_num++;
                    }
                }
                if ($args_num == 1) {
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

