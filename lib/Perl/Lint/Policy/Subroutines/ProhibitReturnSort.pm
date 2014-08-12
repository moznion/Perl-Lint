package Perl::Lint::Policy::Subroutines::ProhibitReturnSort;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"return" statement followed by "sort"',
    EXPL => 'Behavior is undefined if called in scalar context',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == RETURN) {
            my $next_token = $tokens->[$i+1];
            if ($next_token->{type} == BUILTIN_FUNC && $next_token->{data} eq 'sort') {
                my $is_in_postposition_if = 0;
                my $is_wantarray = 0;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        if (!$is_wantarray) {
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
                    elsif ($token_type == IF_STATEMENT) {
                        $is_in_postposition_if = 1;
                    }
                    elsif ($token_type == BUILTIN_FUNC && $token->{data} eq 'wantarray' && $is_in_postposition_if) {
                        $is_wantarray = 1;
                    }
                }
                next;
            }
        }
        elsif ($token_type == IF_STATEMENT) {
            my $left_brace_num = 0;
            my $is_wantarray   = 0;
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                if ($token_type == LEFT_BRACE) {
                    $left_brace_num++;
                }
                elsif ($token_type == RIGHT_BRACE) {
                    $left_brace_num--;
                    last if ($left_brace_num <= 0);
                }
                elsif ($token_type == BUILTIN_FUNC && $token->{data} eq 'wantarray') {
                    $is_wantarray = 1;
                }
                elsif (!$is_wantarray) {
                    my $next_token = $tokens->[$i+1];
                    if ($next_token && $next_token->{type} == BUILTIN_FUNC && $next_token->{data} eq 'sort') {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                        next;
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

