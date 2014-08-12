package Perl::Lint::Policy::TestingAndDebugging::ProhibitNoWarnings;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Warnings disabled',
    EXPL => [431],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @arg_allows;
    if (my $allow = $args->{prohibit_no_warnings}->{allow}) {
        @arg_allows = map { lc $_ } split(/[\s,]/, $allow);
    }
    my $allow_with_category_restriction = $args->{prohibit_no_warnings}->{allow_with_category_restriction};

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};

        if ($token_type == BUILTIN_FUNC and $token->{data} eq 'no') {
            $token = $tokens->[++$i];

            my @allows;
            if ($token->{type} == KEY && $token->{data} eq 'warnings') {
                for ($i++; $i < $token_num; $i++) {
                    $token = $tokens->[$i];
                    $token_type = $token->{type};

                    if ($token_type == STRING || $token_type == RAW_STRING) {
                        push @allows, $token->{data};
                    }
                    elsif ($token_type == REG_EXP) {
                        push @allows, split(/ /, $token->{data});
                    }
                    elsif ($token_type == SEMI_COLON || !$tokens->[$i+1]) {
                        last if @allows && $allow_with_category_restriction;

                        for my $arg_allow (@arg_allows) {
                            @allows = grep { $_ ne $arg_allow } @allows;
                        }
                        if (!@arg_allows || @allows) {
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
        }
    }

    return \@violations;
}

1;

