package Perl::Lint::Policy::BuiltinFunctions::ProhibitUniversalCan;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'UNIVERSAL::can should not be used as a function',
    EXPL => 'Use eval{$obj->can($pkg)} instead',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == KEY && $token_data eq 'can') { # for can()
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == NAMESPACE && $token_data eq 'UNIVERSAL') { # for UNIVERSAL::can()
            $i += 2; # skip the name space resolver
            $token = $tokens->[$i];
            if ($token->{type} == NAMESPACE && $token->{data} eq 'can') {
                if ($tokens->[++$i]->{type} == LEFT_PAREN) {
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

