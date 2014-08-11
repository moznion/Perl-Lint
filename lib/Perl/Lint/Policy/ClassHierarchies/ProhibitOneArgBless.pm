package Perl::Lint::Policy::ClassHierarchies::ProhibitOneArgBless;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'One-argument "bless" used',
    EXPL => [365],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'bless') {
            my $left_paren_num   = 0;
            my $left_brace_num   = 0;
            my $left_bracket_num = 0;
            my $comma_num = 0;

            $i++ if $tokens->[$i+1]->{type} == LEFT_PAREN;

            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};
                my $token_data = $token->{data};

                if ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                }
                elsif ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == LEFT_BRACKET) {
                    $left_bracket_num++;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    $left_paren_num--;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    $left_brace_num--;
                }
                elsif ($token_type == RIGHT_BRACKET) {
                    $left_bracket_num--;
                }
                elsif (
                    ($token_type == COMMA || $token_type == ARROW) &&
                    $left_paren_num   <= 0 &&
                    $left_brace_num   <= 0 &&
                    $left_bracket_num <= 0
                ) {
                    $comma_num++;
                }
                elsif (
                    $token_type == SEMI_COLON &&
                    $left_paren_num   <= 0    &&
                    $left_brace_num   <= 0    &&
                    $left_bracket_num <= 0
                ) {
                    if ($comma_num == 0) {
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

    return \@violations;
}

1;

