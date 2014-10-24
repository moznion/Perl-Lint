package Perl::Lint::Policy::BuiltinFunctions::RequireSimpleSortBlock;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Sort blocks should have a single statement',
    EXPL => [149],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'sort') {
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                $token = $tokens->[++$i];
            }

            my $token_type = $token->{type};

            if ($token_type != LEFT_BRACE) {
                next;
            }

            my $left_brace_num = 1;
            my $concat_stmt = ''; # XXX
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    if (--$left_brace_num <= 0) {
                        if (scalar(@_ = split /;/, $concat_stmt) > 1) { # XXX
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                        last;
                    }
                }
                else {
                    $concat_stmt .= $token->{data};
                }
            }
        }
    }

    return \@violations;
}

1;

