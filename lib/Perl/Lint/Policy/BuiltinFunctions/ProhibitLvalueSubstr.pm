package Perl::Lint::Policy::BuiltinFunctions::ProhibitLvalueSubstr;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Lvalue form of "substr" used',
    EXPL => [165],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'substr') {
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    $token = $tokens->[++$i];
                    $token_type = $token->{type};

                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            my $next_token = $tokens->[++$i];
                            if ($next_token->{type} == ASSIGN) {
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
                }
            }
        }
        elsif ($token_type == USE_DECL) {
            $token = $tokens->[++$i];
            if ($token->{type} == DOUBLE && $token->{data} <= 5.004) {
                return [];
            }
        }
    }

    return \@violations;
}

1;

