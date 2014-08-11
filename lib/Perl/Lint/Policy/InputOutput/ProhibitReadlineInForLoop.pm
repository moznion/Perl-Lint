package Perl::Lint::Policy::InputOutput::ProhibitReadlineInForLoop;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Readline inside "for" loop',
    EXPL => [211],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == FOR_STATEMENT || $token_type == FOREACH_STATEMENT) {
            $i++;
            $token = $tokens->[$i];
            $token_type = $token->{type};
            if ($token_type == DIAMOND || $token_type == LESS) {
                #                                        ~~~~ XXX should be HandleDecl in fact
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }

            for (; my $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                my $left_paren_num = 0;
                if ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                    for ($i++; my $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }
                        elsif ($token_type == RIGHT_PAREN) {
                            last if --$left_paren_num <= 0;
                        }
                        elsif ($token_type == DIAMOND) {
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
                                $token_type = $token->{type};
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
                    }
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

