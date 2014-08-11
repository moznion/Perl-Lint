package Perl::Lint::Policy::BuiltinFunctions::ProhibitUniversalIsa;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'UNIVERSAL::isa should not be used as a function',
    EXPL => 'Use eval{$obj->isa($pkg)} instead',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == KEY && $token_data eq 'isa') { # for isa()
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
        elsif ($token_type == NAMESPACE && $token_data eq 'UNIVERSAL') { # for UNIVERSAL::isa()
            $i += 2; # skip the name space resolver
            $token = $tokens->[$i];
            if ($token->{type} == NAMESPACE && $token->{data} eq 'isa') {
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

