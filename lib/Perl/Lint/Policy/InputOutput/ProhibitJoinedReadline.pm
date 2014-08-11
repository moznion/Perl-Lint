package Perl::Lint::Policy::InputOutput::ProhibitJoinedReadline;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use "local $/ = undef" or File::Slurp instead of joined readline',
    EXPL => [213],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};
        if ($token_type == BUILTIN_FUNC && $token_data eq 'join') {
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};

                if ($token_type == DIAMOND) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
                elsif ($token_type == HANDLE_DELIM) {
                    for ($i++; my $token = $tokens->[$i]; $i++) {
                        my $token_type = $token->{type};
                        if ($token_type == HANDLE_DELIM) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            last;
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

