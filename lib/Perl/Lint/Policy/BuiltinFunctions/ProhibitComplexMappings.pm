package Perl::Lint::Policy::BuiltinFunctions::ProhibitComplexMappings;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Map blocks should have a single statement',
    EXPL => [113],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_statements = $args->{prohibit_complex_mappings}->{max_statements} || 1;
    if (--$max_statements < 0) {
        $max_statements = 0;
    }

    my @violations;
    my $statements_num = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'map') {
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                $token = $tokens->[++$i];
            }

            if ($token->{type} != LEFT_BRACE) {
                next;
            }

            my $left_brace_num = 1;
            my $placed_semi_colon = 0;
            for ($i++; my $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == IF_STATEMENT) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    last;
                }
                elsif ($token_type == DO) { # skip semi-colons that are in do statement
                    $token = $tokens->[++$i];
                    if ($token->{type} == LEFT_BRACE) {
                        my $left_brace_num = 1;
                        for ($i++; my $token = $tokens->[$i]; $i++) {
                            $token_type = $token->{type};
                            if ($token_type == LEFT_BRACE) {
                                $left_brace_num++;
                            }
                            elsif ($token_type == RIGHT_BRACE) {
                                last if --$left_brace_num <= 0;
                            }
                        }
                    }
                }
                elsif ($token_type == SEMI_COLON) {
                    my $next_token = $tokens->[$i+1];
                    my $next_token_type = $next_token->{type};
                    $statements_num++;
                    if ($statements_num > $max_statements && ($left_brace_num != 1 || ($next_token_type && $next_token_type != RIGHT_BRACE))) {
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
                elsif ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    last if --$left_brace_num <= 0;
                }
            }
        }
    }

    return \@violations;
}

1;

